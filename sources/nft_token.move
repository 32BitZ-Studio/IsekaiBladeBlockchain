
// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: NFT Token - NFT struct, mint restrictions, metadata & attributes
module isekai_blade::nft_token;

use sui::display;
use sui::event::emit;
use sui::package::{Self, Publisher};
use std::string::{String, utf8};
use std::option::{Self, Option};
use isekai_blade::access_control::{Self, OwnerCap, RoleCap};
use isekai_blade::attributes_chain::{Self, AttributesChain};

// === Error Codes ===
const ENotAuthorized: u64 = 0;
const EInvalidTokenId: u64 = 1;
const ETokenNotTransferable: u64 = 2;
const EInvalidMetadata: u64 = 3;
const ECollectionNotFound: u64 = 4;

// === Constants ===
const TOKEN_VERSION: u64 = 1;
const CHARACTER_ITEM_TYPE: u8 = 5;

// === Structs ===

/// Main NFT token structure with comprehensive metadata
public struct IsekaiBlade has key, store {
    id: UID,
    // Core metadata
    name: String,
    description: String,
    image_url: String,
    // Game-specific properties
    item_type: u8,
    rarity: u8,
    // Cross-game compatibility
    attributes: AttributesChain,
    // Collection information
    collection_id: ID,
    // Transfer restrictions
    is_transferable: bool,
    is_locked_to_game: bool,
    // Metadata compliance
    external_url: String,
    animation_url: String,
    // Provenance
    creator: address,
    minted_at: u64,
    // Upgrade tracking
    upgrade_count: u64,
    last_upgrade: u64,
}

/// Token metadata following Sui standards
public struct TokenMetadata has store, copy, drop {
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    animation_url: String,
    attributes: vector<TokenAttribute>,
}

/// Individual token attribute for metadata
public struct TokenAttribute has store, copy, drop {
    trait_type: String,
    value: String,
    display_type: String,
}

/// One-Time-Witness for token creation
public struct NFT_TOKEN has drop {}

// === Events ===

public struct TokenMinted has copy, drop {
    token_id: ID,
    collection_id: ID,
    recipient: address,
    minter: address,
    name: String,
    rarity: u8,
    item_type: u8,
}

public struct TokenBurned has copy, drop {
    token_id: ID,
    owner: address,
}

public struct TokenLocked has copy, drop {
    token_id: ID,
    locked_to_game: bool,
}

public struct TokenUpgraded has copy, drop {
    token_id: ID,
    upgrade_count: u64,
    upgraded_by: address,
}

public struct MetadataUpdated has copy, drop {
    token_id: ID,
    field: String,
    old_value: String,
    new_value: String,
}

// === Initializer ===

fun init(otw: NFT_TOKEN, ctx: &mut TxContext) {
    // Create display object for NFT metadata
    let keys = vector[
        utf8(b"name"),
        utf8(b"description"),
        utf8(b"image_url"),
        utf8(b"external_url"),
        utf8(b"animation_url"),
        utf8(b"project_url"),
        utf8(b"creator"),
        utf8(b"rarity"),
        utf8(b"item_type"),
        utf8(b"attributes"),
        utf8(b"collection_id"),
        utf8(b"minted_at"),
        utf8(b"upgrade_count"),
    ];

    let values = vector[
        utf8(b"{name}"),
        utf8(b"{description}"),
        utf8(b"{image_url}"),
        utf8(b"{external_url}"),
        utf8(b"{animation_url}"),
        utf8(b"https://marketplace.isekaiblade.com"),
        utf8(b"{creator}"),
        utf8(b"{rarity}"),
        utf8(b"{item_type}"),
        utf8(b"{attributes}"),
        utf8(b"{collection_id}"),
        utf8(b"{minted_at}"),
        utf8(b"{upgrade_count}"),
    ];

    let publisher = package::claim(otw, ctx);
    let mut display = display::new_with_fields<IsekaiBlade>(
        &publisher,
        keys,
        values,
        ctx,
    );

    display::update_version(&mut display);

    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(display, ctx.sender());
}

// === Minting Functions ===

/// Mint new NFT token (owner only)
public fun mint_token(
    _owner_cap: &OwnerCap,
    collection_id: ID,
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    animation_url: String,
    item_type: u8,
    rarity: u8,
    recipient: address,
    ctx: &mut TxContext
): IsekaiBlade {
    let mut attributes = attributes_chain::new_attributes_chain(ctx);

    // Add core attributes
    attributes_chain::add_attribute(
        &mut attributes,
        utf8(b"item_type"),
        attributes_chain::create_number_attribute((item_type as u64)),
        object::id_from_address(recipient),
        ctx
    );

    attributes_chain::add_attribute(
        &mut attributes,
        utf8(b"rarity"),
        attributes_chain::create_number_attribute((rarity as u64)),
        object::id_from_address(recipient),
        ctx
    );

    let token = IsekaiBlade {
        id: object::new(ctx),
        name,
        description,
        image_url,
        item_type,
        rarity,
        attributes,
        collection_id,
        is_transferable: true,
        is_locked_to_game: false,
        external_url,
        animation_url,
        creator: ctx.sender(),
        minted_at: tx_context::epoch(ctx),
        upgrade_count: 0,
        last_upgrade: 0,
    };

    emit(TokenMinted {
        token_id: token.id.to_inner(),
        collection_id,
        recipient,
        minter: ctx.sender(),
        name: token.name,
        rarity,
        item_type,
    });

    token
}

/// Mint with role-based access
public fun mint_with_role(
    role_cap: &RoleCap,
    collection_id: ID,
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    animation_url: String,
    item_type: u8,
    rarity: u8,
    recipient: address,
    ctx: &mut TxContext
): IsekaiBlade {
    // Verify minter role
    assert!(
        access_control::get_role(role_cap) == access_control::minter_role(),
        ENotAuthorized
    );

    // Use internal minting logic without owner cap check
    mint_internal(
        collection_id,
        name,
        description,
        image_url,
        external_url,
        animation_url,
        item_type,
        rarity,
        recipient,
        ctx
    )
}

/// Mint character NFT with required attributes (owner only)
public fun mint_character_token(
    _owner_cap: &OwnerCap,
    collection_id: ID,
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    animation_url: String,
    rarity: u8,
    strength: u64,
    dexterity: u64,
    constitution: u64,
    chakra: u64,
    addition: String,
    recipient: address,
    ctx: &mut TxContext
): IsekaiBlade {
    // Create character attributes with validation
    let attributes = attributes_chain::create_character_attributes(
        strength,
        dexterity,
        constitution,
        chakra,
        addition,
        object::id_from_address(recipient),
        ctx
    );

    let token = IsekaiBlade {
        id: object::new(ctx),
        name,
        description,
        image_url,
        item_type: CHARACTER_ITEM_TYPE,
        rarity,
        attributes,
        collection_id,
        is_transferable: true,
        is_locked_to_game: false,
        external_url,
        animation_url,
        creator: ctx.sender(),
        minted_at: tx_context::epoch(ctx),
        upgrade_count: 0,
        last_upgrade: 0,
    };

    emit(TokenMinted {
        token_id: token.id.to_inner(),
        collection_id,
        recipient,
        minter: ctx.sender(),
        name: token.name,
        rarity,
        item_type: CHARACTER_ITEM_TYPE,
    });

    token
}

/// Mint character NFT with role-based access
public fun mint_character_with_role(
    role_cap: &RoleCap,
    collection_id: ID,
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    animation_url: String,
    rarity: u8,
    strength: u64,
    dexterity: u64,
    constitution: u64,
    chakra: u64,
    addition: String,
    recipient: address,
    ctx: &mut TxContext
): IsekaiBlade {
    // Verify minter role
    assert!(
        access_control::get_role(role_cap) == access_control::minter_role(),
        ENotAuthorized
    );

    // Create character attributes with validation
    let attributes = attributes_chain::create_character_attributes(
        strength,
        dexterity,
        constitution,
        chakra,
        addition,
        object::id_from_address(recipient),
        ctx
    );

    let token = IsekaiBlade {
        id: object::new(ctx),
        name,
        description,
        image_url,
        item_type: CHARACTER_ITEM_TYPE,
        rarity,
        attributes,
        collection_id,
        is_transferable: true,
        is_locked_to_game: false,
        external_url,
        animation_url,
        creator: ctx.sender(),
        minted_at: tx_context::epoch(ctx),
        upgrade_count: 0,
        last_upgrade: 0,
    };

    emit(TokenMinted {
        token_id: token.id.to_inner(),
        collection_id,
        recipient,
        minter: ctx.sender(),
        name: token.name,
        rarity,
        item_type: CHARACTER_ITEM_TYPE,
    });

    token
}

/// Burn NFT token
public fun burn_token(token: IsekaiBlade, ctx: &mut TxContext) {
    let IsekaiBlade {
        id,
        name: _,
        description: _,
        image_url: _,
        item_type: _,
        rarity: _,
        attributes,
        collection_id: _,
        is_transferable: _,
        is_locked_to_game: _,
        external_url: _,
        animation_url: _,
        creator: _,
        minted_at: _,
        upgrade_count: _,
        last_upgrade: _
    } = token;

    emit(TokenBurned {
        token_id: id.to_inner(),
        owner: ctx.sender(),
    });

    // Properly destroy attributes before deleting UID
    attributes_chain::destroy_attributes_chain(attributes);
    id.delete();
}

// === Mutation Functions ===

/// Update token metadata (admin only)
public fun update_metadata(
    _owner_cap: &OwnerCap,
    token: &mut IsekaiBlade,
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    animation_url: String,
) {
    let old_name = token.name;
    token.name = name;
    token.description = description;
    token.image_url = image_url;
    token.external_url = external_url;
    token.animation_url = animation_url;

    emit(MetadataUpdated {
        token_id: token.id.to_inner(),
        field: utf8(b"name"),
        old_value: old_name,
        new_value: name,
    });
}

/// Lock token to specific game
public fun lock_to_game(token: &mut IsekaiBlade, locked: bool, ctx: &mut TxContext) {
    token.is_locked_to_game = locked;

    emit(TokenLocked {
        token_id: token.id.to_inner(),
        locked_to_game: locked,
    });
}

/// Set transferability
public fun set_transferable(
    _owner_cap: &OwnerCap,
    token: &mut IsekaiBlade,
    transferable: bool
) {
    token.is_transferable = transferable;
}

/// Upgrade token (increment upgrade counter)
public fun upgrade_token(
    token: &mut IsekaiBlade,
    ctx: &mut TxContext
) {
    token.upgrade_count = token.upgrade_count + 1;
    token.last_upgrade = tx_context::epoch(ctx);

    emit(TokenUpgraded {
        token_id: token.id.to_inner(),
        upgrade_count: token.upgrade_count,
        upgraded_by: ctx.sender(),
    });
}

/// Update character attributes (owner only)
public fun update_character_attributes(
    _owner_cap: &OwnerCap,
    token: &mut IsekaiBlade,
    strength: Option<u64>,
    dexterity: Option<u64>,
    constitution: Option<u64>,
    chakra: Option<u64>,
    addition: Option<String>,
    ctx: &mut TxContext
) {
    // Ensure this is a character token
    assert!(token.item_type == CHARACTER_ITEM_TYPE, EInvalidTokenId);

    // Update attributes with validation
    attributes_chain::update_character_attributes(
        &mut token.attributes,
        strength,
        dexterity,
        constitution,
        chakra,
        addition,
        token.id.to_inner(),
        ctx
    );
}

// === View Functions ===

public fun name(token: &IsekaiBlade): String { token.name }
public fun description(token: &IsekaiBlade): String { token.description }
public fun image_url(token: &IsekaiBlade): String { token.image_url }
public fun external_url(token: &IsekaiBlade): String { token.external_url }
public fun animation_url(token: &IsekaiBlade): String { token.animation_url }
public fun item_type(token: &IsekaiBlade): u8 { token.item_type }
public fun rarity(token: &IsekaiBlade): u8 { token.rarity }
public fun collection_id(token: &IsekaiBlade): ID { token.collection_id }
public fun creator(token: &IsekaiBlade): address { token.creator }
public fun minted_at(token: &IsekaiBlade): u64 { token.minted_at }
public fun upgrade_count(token: &IsekaiBlade): u64 { token.upgrade_count }
public fun last_upgrade(token: &IsekaiBlade): u64 { token.last_upgrade }
public fun is_transferable(token: &IsekaiBlade): bool { token.is_transferable }
public fun is_locked_to_game(token: &IsekaiBlade): bool { token.is_locked_to_game }

/// Get attributes chain reference
public fun attributes(token: &IsekaiBlade): &AttributesChain {
    &token.attributes
}

/// Get mutable attributes chain reference
public fun attributes_mut(token: &mut IsekaiBlade): &mut AttributesChain {
    &mut token.attributes
}

/// Check if token is a character
public fun is_character(token: &IsekaiBlade): bool {
    token.item_type == CHARACTER_ITEM_TYPE
}

/// Get character attributes (returns: strength, dexterity, constitution, chakra, addition)
public fun get_character_attributes(token: &IsekaiBlade): (u64, u64, u64, u64, String) {
    assert!(token.item_type == CHARACTER_ITEM_TYPE, EInvalidTokenId);
    attributes_chain::get_character_attributes(&token.attributes)
}

/// Get token metadata in standard format
public fun get_metadata(token: &IsekaiBlade): TokenMetadata {
    let mut attributes_vec = vector::empty<TokenAttribute>();

    // Convert attributes chain to vector format
    let attr_names = attributes_chain::get_attribute_names(&token.attributes);
    let mut i = 0;
    while (i < vector::length(&attr_names)) {
        let name = *vector::borrow(&attr_names, i);
        if (attributes_chain::has_attribute(&token.attributes, name)) {
            let attr = attributes_chain::get_attribute(&token.attributes, name);
            // This is simplified - in practice you'd handle different attribute types
            vector::push_back(&mut attributes_vec, TokenAttribute {
                trait_type: name,
                value: utf8(b"value"), // Simplified
                display_type: utf8(b"string"),
            });
        };
        i = i + 1;
    };

    TokenMetadata {
        name: token.name,
        description: token.description,
        image_url: token.image_url,
        external_url: token.external_url,
        animation_url: token.animation_url,
        attributes: attributes_vec,
    }
}

// === Transfer Override ===

/// Custom transfer with restrictions
public fun transfer_token(token: IsekaiBlade, recipient: address) {
    assert!(token.is_transferable, ETokenNotTransferable);
    transfer::public_transfer(token, recipient);
}

// === Internal Helper Functions ===

fun mint_internal(
    collection_id: ID,
    name: String,
    description: String,
    image_url: String,
    external_url: String,
    animation_url: String,
    item_type: u8,
    rarity: u8,
    recipient: address,
    ctx: &mut TxContext
): IsekaiBlade {
    let mut attributes = attributes_chain::new_attributes_chain(ctx);

    // Add core attributes
    attributes_chain::add_attribute(
        &mut attributes,
        utf8(b"item_type"),
        attributes_chain::create_number_attribute((item_type as u64)),
        object::id_from_address(recipient),
        ctx
    );

    attributes_chain::add_attribute(
        &mut attributes,
        utf8(b"rarity"),
        attributes_chain::create_number_attribute((rarity as u64)),
        object::id_from_address(recipient),
        ctx
    );

    let token = IsekaiBlade {
        id: object::new(ctx),
        name,
        description,
        image_url,
        item_type,
        rarity,
        attributes,
        collection_id,
        is_transferable: true,
        is_locked_to_game: false,
        external_url,
        animation_url,
        creator: ctx.sender(),
        minted_at: tx_context::epoch(ctx),
        upgrade_count: 0,
        last_upgrade: 0,
    };

    emit(TokenMinted {
        token_id: token.id.to_inner(),
        collection_id,
        recipient,
        minter: ctx.sender(),
        name: token.name,
        rarity,
        item_type,
    });

    token
}

// === Test Functions ===

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(NFT_TOKEN {}, ctx);
}

#[test_only]
public fun create_test_token(
    collection_id: ID,
    name: String,
    ctx: &mut TxContext
): IsekaiBlade {
    mint_internal(
        collection_id,
        name,
        utf8(b"Test token"),
        utf8(b"https://example.com/image.png"),
        utf8(b"https://example.com"),
        utf8(b""),
        1, // sword type
        2, // rare
        ctx.sender(),
        ctx
    )
}
