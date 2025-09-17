// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: Collection - Collection settings, royalties
module isekai_blade::collection;

use sui::event::emit;
use sui::coin::Coin;
use sui::balance::{Self, Balance};
use sui::sui::SUI;
use std::string::{String, utf8};
use isekai_blade::access_control::OwnerCap;

// === Error Codes ===
const ENotAuthorized: u64 = 0;
const EInvalidRoyaltyRate: u64 = 1;
const EInsufficientBalance: u64 = 3;

// === Constants ===
const MAX_ROYALTY_RATE: u64 = 1000; // 10% max (basis points)
const BASIS_POINTS: u64 = 10000; // 100.00%

// === Structs ===

/// Collection configuration and metadata
public struct Collection has key {
    id: UID,
    name: String,
    description: String,
    symbol: String,
    image_url: String,
    external_url: String,
    // Creator and ownership
    creator: address,
    owner: address,
    // Royalty settings
    royalty_rate: u64, // in basis points (1% = 100 bp)
    royalty_recipient: address,
    // Collection settings
    max_supply: u64,
    current_supply: u64,
    is_active: bool,
    is_mutable: bool,
    // Revenue tracking
    total_revenue: Balance<SUI>,
    total_royalties: Balance<SUI>,
    // Metadata
    created_at: u64,
    updated_at: u64,
}

/// Collection statistics
public struct CollectionStats has store, copy, drop {
    total_minted: u64,
    total_burned: u64,
    total_transferred: u64,
    floor_price: u64,
    volume: u64,
    last_sale_price: u64,
}

/// Royalty information for marketplace integration
public struct RoyaltyInfo has store, copy, drop {
    recipient: address,
    rate: u64, // basis points
}

// === Events ===

public struct CollectionCreated has copy, drop {
    collection_id: ID,
    name: String,
    creator: address,
    max_supply: u64,
    royalty_rate: u64,
}

public struct CollectionUpdated has copy, drop {
    collection_id: ID,
    field: String,
    old_value: String,
    new_value: String,
}

public struct RoyaltyUpdated has copy, drop {
    collection_id: ID,
    old_rate: u64,
    new_rate: u64,
    old_recipient: address,
    new_recipient: address,
}

public struct RoyaltyPaid has copy, drop {
    collection_id: ID,
    sale_price: u64,
    royalty_amount: u64,
    recipient: address,
    payer: address,
}

public struct RevenueWithdrawn has copy, drop {
    collection_id: ID,
    amount: u64,
    recipient: address,
}

// === Public Functions ===

/// Create a new collection
public fun create_collection(
    _owner_cap: &OwnerCap,
    name: String,
    description: String,
    symbol: String,
    image_url: String,
    external_url: String,
    max_supply: u64,
    royalty_rate: u64,
    royalty_recipient: address,
    ctx: &mut TxContext
): Collection {
    assert!(royalty_rate <= MAX_ROYALTY_RATE, EInvalidRoyaltyRate);

    let collection = Collection {
        id: object::new(ctx),
        name,
        description,
        symbol,
        image_url,
        external_url,
        creator: ctx.sender(),
        owner: ctx.sender(),
        royalty_rate,
        royalty_recipient,
        max_supply,
        current_supply: 0,
        is_active: true,
        is_mutable: true,
        total_revenue: balance::zero(),
        total_royalties: balance::zero(),
        created_at: tx_context::epoch(ctx),
        updated_at: tx_context::epoch(ctx),
    };

    emit(CollectionCreated {
        collection_id: collection.id.to_inner(),
        name,
        creator: ctx.sender(),
        max_supply,
        royalty_rate,
    });

    collection
}

/// Update collection metadata (owner only)
public fun update_collection_metadata(
    _owner_cap: &OwnerCap,
    collection: &mut Collection,
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    ctx: &mut TxContext
) {
    assert!(collection.is_mutable, ENotAuthorized);
    
    let old_name = collection.name;
    collection.name = name;
    collection.description = description;
    collection.image_url = image_url;
    collection.external_url = external_url;
    collection.updated_at = tx_context::epoch(ctx);

    emit(CollectionUpdated {
        collection_id: collection.id.to_inner(),
        field: utf8(b"name"),
        old_value: old_name,
        new_value: name,
    });
}

/// Update royalty settings (owner only)
public fun update_royalty_settings(
    _owner_cap: &OwnerCap,
    collection: &mut Collection,
    new_rate: u64,
    new_recipient: address,
    ctx: &mut TxContext
) {
    assert!(new_rate <= MAX_ROYALTY_RATE, EInvalidRoyaltyRate);

    let old_rate = collection.royalty_rate;
    let old_recipient = collection.royalty_recipient;
    
    collection.royalty_rate = new_rate;
    collection.royalty_recipient = new_recipient;
    collection.updated_at = tx_context::epoch(ctx);

    emit(RoyaltyUpdated {
        collection_id: collection.id.to_inner(),
        old_rate,
        new_rate,
        old_recipient,
        new_recipient,
    });
}

/// Increment supply when minting
public fun increment_supply(collection: &mut Collection) {
    collection.current_supply = collection.current_supply + 1;
}

/// Decrement supply when burning
public fun decrement_supply(collection: &mut Collection) {
    if (collection.current_supply > 0) {
        collection.current_supply = collection.current_supply - 1;
    };
}

/// Set collection active status
public fun set_active(
    _owner_cap: &OwnerCap,
    collection: &mut Collection,
    active: bool,
    ctx: &mut TxContext
) {
    collection.is_active = active;
    collection.updated_at = tx_context::epoch(ctx);
}

/// Make collection immutable
public fun make_immutable(
    _owner_cap: &OwnerCap,
    collection: &mut Collection,
    ctx: &mut TxContext
) {
    collection.is_mutable = false;
    collection.updated_at = tx_context::epoch(ctx);
}

/// Transfer ownership
public fun transfer_ownership(
    _owner_cap: &OwnerCap,
    collection: &mut Collection,
    new_owner: address,
    ctx: &mut TxContext
) {
    collection.owner = new_owner;
    collection.updated_at = tx_context::epoch(ctx);
}

// === Royalty Functions ===

/// Calculate royalty amount for a sale
public fun calculate_royalty(collection: &Collection, sale_price: u64): u64 {
    (sale_price * collection.royalty_rate) / BASIS_POINTS
}

/// Pay royalty to collection (called by marketplace)
public fun pay_royalty(
    collection: &mut Collection,
    mut payment: Coin<SUI>,
    sale_price: u64,
    ctx: &mut TxContext
): Coin<SUI> {
    let royalty_amount = calculate_royalty(collection, sale_price);
    let payment_amount = payment.value();
    
    if (royalty_amount > 0 && payment_amount >= royalty_amount) {
        let royalty_coin = payment.split(royalty_amount, ctx);
        let royalty_balance = royalty_coin.into_balance();
        
        balance::join(&mut collection.total_royalties, royalty_balance);

        emit(RoyaltyPaid {
            collection_id: collection.id.to_inner(),
            sale_price,
            royalty_amount,
            recipient: collection.royalty_recipient,
            payer: ctx.sender(),
        });
    };

    payment
}

/// Withdraw royalties (recipient only)
public fun withdraw_royalties(
    collection: &mut Collection,
    amount: u64,
    ctx: &mut TxContext
): Coin<SUI> {
    assert!(ctx.sender() == collection.royalty_recipient, ENotAuthorized);
    assert!(balance::value(&collection.total_royalties) >= amount, EInsufficientBalance);

    let withdrawn_balance = balance::split(&mut collection.total_royalties, amount);
    
    emit(RevenueWithdrawn {
        collection_id: collection.id.to_inner(),
        amount,
        recipient: ctx.sender(),
    });

    withdrawn_balance.into_coin(ctx)
}

/// Withdraw all royalties
public fun withdraw_all_royalties(
    collection: &mut Collection,
    ctx: &mut TxContext
): Coin<SUI> {
    let amount = balance::value(&collection.total_royalties);
    withdraw_royalties(collection, amount, ctx)
}

// === View Functions ===

public fun name(collection: &Collection): String { collection.name }
public fun description(collection: &Collection): String { collection.description }
public fun symbol(collection: &Collection): String { collection.symbol }
public fun image_url(collection: &Collection): String { collection.image_url }
public fun external_url(collection: &Collection): String { collection.external_url }
public fun creator(collection: &Collection): address { collection.creator }
public fun owner(collection: &Collection): address { collection.owner }
public fun royalty_rate(collection: &Collection): u64 { collection.royalty_rate }
public fun royalty_recipient(collection: &Collection): address { collection.royalty_recipient }
public fun max_supply(collection: &Collection): u64 { collection.max_supply }
public fun current_supply(collection: &Collection): u64 { collection.current_supply }
public fun is_active(collection: &Collection): bool { collection.is_active }
public fun is_mutable(collection: &Collection): bool { collection.is_mutable }
public fun created_at(collection: &Collection): u64 { collection.created_at }
public fun updated_at(collection: &Collection): u64 { collection.updated_at }

/// Get royalty info for marketplace integration
public fun get_royalty_info(collection: &Collection): RoyaltyInfo {
    RoyaltyInfo {
        recipient: collection.royalty_recipient,
        rate: collection.royalty_rate,
    }
}

/// Get total royalties balance
public fun total_royalties_balance(collection: &Collection): u64 {
    balance::value(&collection.total_royalties)
}

/// Get total revenue balance
public fun total_revenue_balance(collection: &Collection): u64 {
    balance::value(&collection.total_revenue)
}

/// Check if supply limit reached
public fun is_supply_limit_reached(collection: &Collection): bool {
    if (collection.max_supply == 0) return false; // Unlimited supply
    collection.current_supply >= collection.max_supply
}

/// Get remaining supply
public fun remaining_supply(collection: &Collection): u64 {
    if (collection.max_supply == 0) return 18446744073709551615u64; // Max u64 for unlimited
    if (collection.current_supply >= collection.max_supply) return 0;
    collection.max_supply - collection.current_supply
}

// === Collection Statistics Functions ===

/// Create collection statistics
public fun create_stats(): CollectionStats {
    CollectionStats {
        total_minted: 0,
        total_burned: 0,
        total_transferred: 0,
        floor_price: 0,
        volume: 0,
        last_sale_price: 0,
    }
}

/// Update collection statistics
public fun update_stats(
    stats: &mut CollectionStats,
    minted: u64,
    burned: u64,
    transferred: u64,
    floor_price: u64,
    volume: u64,
    last_sale_price: u64,
) {
    stats.total_minted = stats.total_minted + minted;
    stats.total_burned = stats.total_burned + burned;
    stats.total_transferred = stats.total_transferred + transferred;
    stats.floor_price = floor_price;
    stats.volume = stats.volume + volume;
    stats.last_sale_price = last_sale_price;
}

// === Validation Functions ===

/// Validate collection can mint new tokens
public fun validate_mint(collection: &Collection): bool {
    collection.is_active && !is_supply_limit_reached(collection)
}

/// Validate royalty recipient
public fun validate_royalty_recipient(recipient: address): bool {
    recipient != @0x0
}

/// Validate royalty rate
public fun validate_royalty_rate(rate: u64): bool {
    rate <= MAX_ROYALTY_RATE
}

// === Test Functions ===

#[test_only]
public fun create_test_collection(ctx: &mut TxContext): Collection {
    Collection {
        id: object::new(ctx),
        name: utf8(b"Test Collection"),
        description: utf8(b"Test Description"),
        symbol: utf8(b"TEST"),
        image_url: utf8(b"https://example.com/image.png"),
        external_url: utf8(b"https://example.com"),
        creator: ctx.sender(),
        owner: ctx.sender(),
        royalty_rate: 250, // 2.5%
        royalty_recipient: ctx.sender(),
        max_supply: 1000,
        current_supply: 0,
        is_active: true,
        is_mutable: true,
        total_revenue: balance::zero(),
        total_royalties: balance::zero(),
        created_at: tx_context::epoch(ctx),
        updated_at: tx_context::epoch(ctx),
    }
}

#[test_only]
public fun get_max_royalty_rate(): u64 {
    MAX_ROYALTY_RATE
}

#[test_only]
public fun get_basis_points(): u64 {
    BASIS_POINTS
}