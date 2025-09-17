// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: Upgrade - Upgrade mechanics & voucher redemption
module isekai_blade::upgrade;

use sui::event::emit;
use sui::table::{Self, Table};
use sui::ecdsa_k1;
use sui::hash::blake2b256;
use sui::bcs;
use std::string::{Self as string, String, utf8};
use isekai_blade::access_control::OwnerCap;
use isekai_blade::nft_token::{Self, IsekaiBlade};
use isekai_blade::attributes_chain::{Self, AttributesChain};

// === Error Codes ===
const EInvalidSignature: u64 = 0;
const EVoucherExpired: u64 = 1;
const EVoucherAlreadyUsed: u64 = 2;
const EInvalidUpgrade: u64 = 3;

// === Structs ===

/// Upgrade voucher with cryptographic proof
public struct UpgradeVoucher has store, drop {
    nonce: u64,
    token_id: ID,
    upgrade_data: String, // JSON-encoded upgrade information
    expiry: u64,
    signature: vector<u8>,
    public_key: vector<u8>,
}

/// Upgrade registry to track used vouchers
public struct UpgradeRegistry has key {
    id: UID,
    used_nonces: Table<u64, bool>,
    authorized_keys: vector<vector<u8>>,
    upgrade_count: u64,
}

/// Upgrade template for common upgrades
public struct UpgradeTemplate has store, copy, drop {
    template_id: String,
    name: String,
    description: String,
    attribute_changes: vector<AttributeChange>,
    cost: u64,
    rarity_requirement: u8,
}

/// Individual attribute change in an upgrade
public struct AttributeChange has store, copy, drop {
    attribute_name: String,
    change_type: u8, // 0: set, 1: add, 2: multiply
    value: String,
}

// === Events ===

public struct TokenUpgraded has copy, drop {
    token_id: ID,
    voucher_nonce: u64,
    upgrade_data: String,
    upgraded_by: address,
    timestamp: u64,
}

public struct VoucherRedeemed has copy, drop {
    nonce: u64,
    token_id: ID,
    redeemer: address,
}

public struct UpgradeTemplateCreated has copy, drop {
    template_id: String,
    name: String,
    cost: u64,
}

// === Public Functions ===

/// Initialize upgrade system
public fun init_upgrade_system(ctx: &mut TxContext): UpgradeRegistry {
    UpgradeRegistry {
        id: object::new(ctx),
        used_nonces: table::new(ctx),
        authorized_keys: vector::empty(),
        upgrade_count: 0,
    }
}

/// Add authorized public key for voucher signing
public fun add_authorized_key(
    _owner_cap: &OwnerCap,
    registry: &mut UpgradeRegistry,
    public_key: vector<u8>
) {
    vector::push_back(&mut registry.authorized_keys, public_key);
}

/// Redeem upgrade voucher
public fun redeem_voucher(
    registry: &mut UpgradeRegistry,
    token: &mut IsekaiBlade,
    voucher: UpgradeVoucher,
    ctx: &mut TxContext
) {
    // Verify voucher hasn't been used
    assert!(!table::contains(&registry.used_nonces, voucher.nonce), EVoucherAlreadyUsed);
    
    // Verify voucher hasn't expired
    assert!(tx_context::epoch(ctx) <= voucher.expiry, EVoucherExpired);
    
    // Verify voucher is for this token
    assert!(voucher.token_id == object::id(token), EInvalidUpgrade);
    
    // Verify signature
    verify_voucher_signature(&voucher, &registry.authorized_keys);
    
    // Mark voucher as used
    table::add(&mut registry.used_nonces, voucher.nonce, true);
    
    // Apply upgrade
    apply_upgrade(token, voucher.upgrade_data, ctx);
    
    // Update registry
    registry.upgrade_count = registry.upgrade_count + 1;
    
    emit(VoucherRedeemed {
        nonce: voucher.nonce,
        token_id: voucher.token_id,
        redeemer: ctx.sender(),
    });
}

/// Create upgrade template
public fun create_upgrade_template(
    _owner_cap: &OwnerCap,
    template_id: String,
    name: String,
    description: String,
    attribute_changes: vector<AttributeChange>,
    cost: u64,
    rarity_requirement: u8,
): UpgradeTemplate {
    let template = UpgradeTemplate {
        template_id,
        name,
        description,
        attribute_changes,
        cost,
        rarity_requirement,
    };

    emit(UpgradeTemplateCreated {
        template_id,
        name,
        cost,
    });

    template
}

/// Apply template upgrade to token
public fun apply_template_upgrade(
    registry: &mut UpgradeRegistry,
    token: &mut IsekaiBlade,
    template: &UpgradeTemplate,
    ctx: &mut TxContext
) {
    // Check rarity requirement
    assert!(nft_token::rarity(token) >= template.rarity_requirement, EInvalidUpgrade);
    
    // Apply attribute changes
    let token_id = object::id(token);
    let attributes = nft_token::attributes_mut(token);
    apply_attribute_changes(attributes, &template.attribute_changes, token_id, ctx);
    
    // Increment token upgrade counter
    nft_token::upgrade_token(token, ctx);
    
    // Update registry
    registry.upgrade_count = registry.upgrade_count + 1;
    
    emit(TokenUpgraded {
        token_id: object::id(token),
        voucher_nonce: 0, // Template upgrades don't use vouchers
        upgrade_data: template.name,
        upgraded_by: ctx.sender(),
        timestamp: tx_context::epoch(ctx),
    });
}

// === Internal Functions ===

/// Verify voucher signature
fun verify_voucher_signature(voucher: &UpgradeVoucher, authorized_keys: &vector<vector<u8>>) {
    // Create message to verify
    let mut message = vector::empty<u8>();
    vector::append(&mut message, bcs::to_bytes(&voucher.nonce));
    vector::append(&mut message, bcs::to_bytes(&voucher.token_id));
    vector::append(&mut message, *string::as_bytes(&voucher.upgrade_data));
    vector::append(&mut message, bcs::to_bytes(&voucher.expiry));
    
    let message_hash = blake2b256(&message);
    
    // Verify signature against authorized keys
    let mut i = 0;
    let mut verified = false;
    while (i < vector::length(authorized_keys)) {
        let public_key = vector::borrow(authorized_keys, i);
        if (*public_key == voucher.public_key) {
            let verified_result = ecdsa_k1::secp256k1_verify(
                &voucher.signature,
                public_key,
                &message_hash,
                0 // hash_type: 0 for blake2b256
            );
            if (verified_result) {
                verified = true;
                break
            };
        };
        i = i + 1;
    };
    
    assert!(verified, EInvalidSignature);
}

/// Apply upgrade to token based on upgrade data
fun apply_upgrade(token: &mut IsekaiBlade, upgrade_data: String, ctx: &mut TxContext) {
    // In a real implementation, you would parse the upgrade_data JSON
    // and apply specific changes. For now, we'll do a simple upgrade
    
    let token_id = object::id(token);
    let attributes = nft_token::attributes_mut(token);
    
    // Example: Add +10 to attack if it exists
    if (attributes_chain::has_attribute(attributes, utf8(b"attack"))) {
        let current_attack = attributes_chain::get_number_attribute(attributes, utf8(b"attack"));
        attributes_chain::update_attribute(
            attributes,
            utf8(b"attack"),
            attributes_chain::create_number_attribute(current_attack + 10),
            token_id,
            ctx
        );
    };
    
    // Increment token upgrade counter
    nft_token::upgrade_token(token, ctx);
    
    emit(TokenUpgraded {
        token_id: object::id(token),
        voucher_nonce: 0, // This would be the actual nonce in practice
        upgrade_data,
        upgraded_by: ctx.sender(),
        timestamp: tx_context::epoch(ctx),
    });
}

/// Apply attribute changes from template
fun apply_attribute_changes(
    attributes: &mut AttributesChain,
    changes: &vector<AttributeChange>,
    token_id: ID,
    ctx: &mut TxContext
) {
    let mut i = 0;
    while (i < vector::length(changes)) {
        let change = vector::borrow(changes, i);
        apply_single_attribute_change(attributes, change, token_id, ctx);
        i = i + 1;
    };
}

/// Apply single attribute change
fun apply_single_attribute_change(
    attributes: &mut AttributesChain,
    change: &AttributeChange,
    token_id: ID,
    ctx: &mut TxContext
) {
    let attr_name = change.attribute_name;
    let change_type = change.change_type;
    
    if (change_type == 0) { // Set value
        if (attributes_chain::has_attribute(attributes, attr_name)) {
            // Parse value as number (simplified)
            let new_value = string_to_u64(change.value);
            attributes_chain::update_attribute(
                attributes,
                attr_name,
                attributes_chain::create_number_attribute(new_value),
                token_id,
                ctx
            );
        };
    } else if (change_type == 1) { // Add value
        if (attributes_chain::has_attribute(attributes, attr_name)) {
            let current_value = attributes_chain::get_number_attribute(attributes, attr_name);
            let add_value = string_to_u64(change.value);
            attributes_chain::update_attribute(
                attributes,
                attr_name,
                attributes_chain::create_number_attribute(current_value + add_value),
                token_id,
                ctx
            );
        };
    } else if (change_type == 2) { // Multiply value
        if (attributes_chain::has_attribute(attributes, attr_name)) {
            let current_value = attributes_chain::get_number_attribute(attributes, attr_name);
            let multiplier = string_to_u64(change.value);
            attributes_chain::update_attribute(
                attributes,
                attr_name,
                attributes_chain::create_number_attribute(current_value * multiplier),
                token_id,
                ctx
            );
        };
    };
}

/// Convert string to u64 (simplified implementation)
fun string_to_u64(s: String): u64 {
    // This is a placeholder - in practice you'd implement proper string parsing
    // For now, return a default value
    let _ = s;
    1
}

// === View Functions ===

public fun is_voucher_used(registry: &UpgradeRegistry, nonce: u64): bool {
    table::contains(&registry.used_nonces, nonce)
}

public fun get_upgrade_count(registry: &UpgradeRegistry): u64 {
    registry.upgrade_count
}

public fun get_authorized_keys(registry: &UpgradeRegistry): vector<vector<u8>> {
    registry.authorized_keys
}

// === Helper Functions ===

/// Create upgrade voucher (for testing)
public fun create_voucher(
    nonce: u64,
    token_id: ID,
    upgrade_data: String,
    expiry: u64,
    signature: vector<u8>,
    public_key: vector<u8>
): UpgradeVoucher {
    UpgradeVoucher {
        nonce,
        token_id,
        upgrade_data,
        expiry,
        signature,
        public_key,
    }
}

/// Create attribute change
public fun create_attribute_change(
    attribute_name: String,
    change_type: u8,
    value: String,
): AttributeChange {
    AttributeChange {
        attribute_name,
        change_type,
        value,
    }
}

// === Test Functions ===

#[test_only]
public fun create_test_registry(ctx: &mut TxContext): UpgradeRegistry {
    init_upgrade_system(ctx)
}

#[test_only]
public fun create_test_voucher(token_id: ID): UpgradeVoucher {
    UpgradeVoucher {
        nonce: 1,
        token_id,
        upgrade_data: utf8(b"test_upgrade"),
        expiry: 1000,
        signature: vector::empty(),
        public_key: vector::empty(),
    }
}