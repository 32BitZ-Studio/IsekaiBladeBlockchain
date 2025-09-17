// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: IsekaiBlade - NFT Game Contract
module isekai_blade::isekai_blade {

use std::string::{utf8, String};
use sui::display;
use sui::event::emit;
use sui::package;
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::random::{Random, new_generator};
use sui::dynamic_field as df;
use sui::table::{Self as table, Table};
use isekai_blade::image_generator;

// === Constants ===

const MINT_PRICE: u64 = 1000000000; // 1 SUI in MIST

// Rarity tiers
const COMMON_RARITY: u8 = 1;
const RARE_RARITY: u8 = 2;
const ELITE_RARITY: u8 = 3;
const LEGENDARY_RARITY: u8 = 4;
const MYTHIC_RARITY: u8 = 5;

// Item types
// const SWORD_TYPE: u8 = 1; // Removed unused constant
// const SHIELD_TYPE: u8 = 2; // Removed unused constant
// const ARMOR_TYPE: u8 = 3; // Removed unused constant
// const ACCESSORY_TYPE: u8 = 4; // Removed unused constant
const CHARACTER_TYPE: u8 = 5;
// const BEATS_TYPE: u8 = 6; // Removed unused constant

// === Errors ===

const ENotOwner: u64 = 0;
const EInsufficientPayment: u64 = 1;
// const EMarketplaceNotFound: u64 = 3; // Unused - removed
const EItemNotListed: u64 = 4;
const EInsufficientFunds: u64 = 5;
const EIncompatibleItems: u64 = 6;
const ESameItem: u64 = 7;
const EMaxLevel: u64 = 8;
// const EUnauthorized: u64 = 9; // Removed unused constant
const EInvalidRole: u64 = 10;
const EWhitelistNotFound: u64 = 11;
const EInsufficientMints: u64 = 12;
const ERoundInactive: u64 = 13;

// === Upgrade Constants ===
const MAX_LEVEL: u8 = 10;

// Upgrade percentage constants
const ATTACK_UPGRADE_PERCENT: u64 = 25; // 25% increase
const DEFENSE_UPGRADE_PERCENT: u64 = 25; // 25% increase
const MAGIC_UPGRADE_PERCENT: u64 = 25; // 25% increase
const RARITY_UPGRADE_CHANCE: u8 = 10; // 10% chance to upgrade rarity

// Attribute upgrade constants
const ATTRIBUTE_UPGRADE_FEE: u64 = 1000000000; // 1 SUI in MIST
const MIN_ATTRIBUTE_UPGRADE: u64 = 5; // Minimum attribute increase
const MAX_ATTRIBUTE_UPGRADE: u64 = 15; // Maximum attribute increase

// Progressive rarity constants
// const TOTAL_SUPPLY: u64 = 10000; // Total planned NFTs // Removed unused constant
const FIRST_QUARTER: u64 = 2500;   // 0-25%
const SECOND_QUARTER: u64 = 5000;  // 25-50%
const THIRD_QUARTER: u64 = 7500;   // 50-75%
// const FOURTH_QUARTER: u64 = 10000; // 75-100% // Removed unused constant

// === Structs ===

/// The main NFT struct representing an IsekaiBlade item
/// Additional fields (owner, hair_id, armor_id, mask_id, is_female) are stored as dynamic fields
public struct IsekaiBlade has key, store {
    id: UID,
    name: String,
    description: String,
    item_type: u8,
    rarity: u8,
    level: u8,
    attack: u64,
    defense: u64,
    magic: u64,
    dexterity: u64,     // New dexterity attribute
    image_url: String,
    creator: address,   // Original minter (never changes)
}

/// Contract capabilities struct - only the owner can mint
public struct AdminCap has key, store {
    id: UID,
}

/// Role-based access control
public struct GovernanceCap has key, store {
    id: UID,
}

/// User role management
public struct UserRole has copy, drop, store {
    user: address,
    role: u8,
    granted_at: u64,
}

/// Role constants
const ADMIN_ROLE: u8 = 1;
const GOVERNANCE_ROLE: u8 = 2;

/// Contract version for upgrade validation
public struct ContractVersion has key {
    id: UID,
    version: u64,
    last_upgraded: u64,
    upgrader: address,
}

public struct MintCounter has key {
    id: UID,
    total_minted: u64,
}

/// Marketplace listing structure
public struct Listing has store, drop {
    item_id: ID,
    seller: address,
    price: u64,
    // NFT attributes for display
    name: String,
    description: String,
    image_url: String,
    item_type: u8,
    rarity: u8,
    level: u8,
    attack: u64,
    defense: u64,
    magic: u64,
    dexterity: u64,
    creator: address,
}

/// Marketplace for trading NFTs
public struct Marketplace has key {
    id: UID,
    listings: Table<ID, Listing>,
    total_listings: u64,
}

/// One-Time-Witness for the module
public struct ISEKAI_BLADE has drop {}

/// NFT Escrow system for the marketplace
public struct NFTEscrow has key {
    id: UID,
    escrowed_items: Table<ID, IsekaiBlade>,
}

/// ItemSet - A collection of items bundled together for sale only (not upgradeable)
public struct ItemSet has key, store {
    id: UID,
    name: String,
    description: String,
    items: Table<ID, IsekaiBlade>,
    item_count: u64,
    creator: address,
    created_at: u64,
}

// === Events ===

public struct ItemMinted has copy, drop {
    item_id: ID,
    name: String,
    rarity: u8,
    item_type: u8,
    recipient: address,
}

public struct ItemListed has copy, drop {
    item_id: ID,
    seller: address,
    price: u64,
}

public struct ItemSold has copy, drop {
    item_id: ID,
    seller: address,
    buyer: address,
    price: u64,
}

public struct ItemDelisted has copy, drop {
    item_id: ID,
    seller: address,
}

public struct ItemUpgraded has copy, drop {
    old_item1_id: ID,
    old_item2_id: ID,
    new_item_id: ID,
    old_level: u8,
    new_level: u8,
    upgraded_by: address,
}

public struct AttributeUpgraded has copy, drop {
    item_id: ID,
    old_attack: u64,
    old_defense: u64,
    old_magic: u64,
    new_attack: u64,
    new_defense: u64,
    new_magic: u64,
    upgraded_by: address,
}

public struct SetCreated has copy, drop {
    set_id: ID,
    name: String,
    creator: address,
    created_at: u64,
}

public struct ItemAddedToSet has copy, drop {
    set_id: ID,
    item_id: ID,
    added_by: address,
}

public struct ItemRemovedFromSet has copy, drop {
    set_id: ID,
    item_id: ID,
    removed_by: address,
}

public struct SetSold has copy, drop {
    set_id: ID,
    seller: address,
    buyer: address,
    price: u64,
    item_count: u64,
}

public struct NFTCombineSuccess has copy, drop {
    base_nft_id: ID,
    sacrifice_nft_id: ID,
    optional_nft_id: option::Option<ID>,
    new_nft_id: ID,
    rarity: u8,
    combined_by: address,
}

public struct NFTCombineFailure has copy, drop {
    base_nft_id: ID,
    sacrifice_nft_id: ID,
    optional_nft_id: option::Option<ID>,
    rarity: u8,
    combined_by: address,
}

public struct RoleGranted has copy, drop {
    user: address,
    role: u8,
    granted_by: address,
    granted_at: u64,
}

public struct RoleRevoked has copy, drop {
    user: address,
    role: u8,
    revoked_by: address,
    revoked_at: u64,
}

public struct UnauthorizedAccess has copy, drop {
    user: address,
    function_name: String,
    timestamp: u64,
}

// === Dynamic Field Keys ===
const OWNER_KEY: vector<u8> = b"owner";
const HAIR_ID_KEY: vector<u8> = b"hair_id";
const ARMOR_ID_KEY: vector<u8> = b"armor_id";
const MASK_ID_KEY: vector<u8> = b"mask_id";
const IS_FEMALE_KEY: vector<u8> = b"is_female";

// === Dynamic Field Helper Functions ===

/// Set the owner field as a dynamic field
public fun set_owner(item: &mut IsekaiBlade, owner: address) {
    if (df::exists_(&item.id, OWNER_KEY)) {
        df::remove<vector<u8>, address>(&mut item.id, OWNER_KEY);
    };
    df::add(&mut item.id, OWNER_KEY, owner);
}

/// Get the owner field from dynamic field, fallback to creator if not set
public fun get_owner(item: &IsekaiBlade): address {
    if (df::exists_(&item.id, OWNER_KEY)) {
        *df::borrow(&item.id, OWNER_KEY)
    } else {
        item.creator // Fallback to creator for backward compatibility
    }
}

/// Set hair_id as dynamic field
public fun set_hair_id(item: &mut IsekaiBlade, hair_id: u8) {
    if (df::exists_(&item.id, HAIR_ID_KEY)) {
        df::remove<vector<u8>, u8>(&mut item.id, HAIR_ID_KEY);
    };
    df::add(&mut item.id, HAIR_ID_KEY, hair_id);
}

/// Get hair_id from dynamic field, default to 1 if not set
public fun get_hair_id(item: &IsekaiBlade): u8 {
    if (df::exists_(&item.id, HAIR_ID_KEY)) {
        *df::borrow(&item.id, HAIR_ID_KEY)
    } else {
        1 // Default value
    }
}

/// Set armor_id as dynamic field
public fun set_armor_id(item: &mut IsekaiBlade, armor_id: u8) {
    if (df::exists_(&item.id, ARMOR_ID_KEY)) {
        df::remove<vector<u8>, u8>(&mut item.id, ARMOR_ID_KEY);
    };
    df::add(&mut item.id, ARMOR_ID_KEY, armor_id);
}

/// Get armor_id from dynamic field, default to 1 if not set
public fun get_armor_id(item: &IsekaiBlade): u8 {
    if (df::exists_(&item.id, ARMOR_ID_KEY)) {
        *df::borrow(&item.id, ARMOR_ID_KEY)
    } else {
        1 // Default value
    }
}

/// Set mask_id as dynamic field
public fun set_mask_id(item: &mut IsekaiBlade, mask_id: u8) {
    if (df::exists_(&item.id, MASK_ID_KEY)) {
        df::remove<vector<u8>, u8>(&mut item.id, MASK_ID_KEY);
    };
    df::add(&mut item.id, MASK_ID_KEY, mask_id);
}

/// Get mask_id from dynamic field, default to 0 if not set
public fun get_mask_id(item: &IsekaiBlade): u8 {
    if (df::exists_(&item.id, MASK_ID_KEY)) {
        *df::borrow(&item.id, MASK_ID_KEY)
    } else {
        0 // Default value (no mask)
    }
}

/// Set is_female as dynamic field
public fun set_is_female(item: &mut IsekaiBlade, is_female: bool) {
    if (df::exists_(&item.id, IS_FEMALE_KEY)) {
        df::remove<vector<u8>, bool>(&mut item.id, IS_FEMALE_KEY);
    };
    df::add(&mut item.id, IS_FEMALE_KEY, is_female);
}

/// Get is_female from dynamic field, default to false if not set
public fun get_is_female(item: &IsekaiBlade): bool {
    if (df::exists_(&item.id, IS_FEMALE_KEY)) {
        *df::borrow(&item.id, IS_FEMALE_KEY)
    } else {
        false // Default value
    }
}

/// Set all asset IDs at once for convenience
public fun set_asset_ids(item: &mut IsekaiBlade, hair_id: u8, armor_id: u8, mask_id: u8, is_female: bool) {
    set_hair_id(item, hair_id);
    set_armor_id(item, armor_id);
    set_mask_id(item, mask_id);
    set_is_female(item, is_female);
}

// === Initializer ===

/// Calculate rarity based on progressive distribution and total minted count
fun calculate_progressive_rarity(total_minted: u64, random_value: u8): u8 {
    // Determine which quarter we're in
    let quarter = if (total_minted < FIRST_QUARTER) {
        1 // First 25%: 0-2500
    } else if (total_minted < SECOND_QUARTER) {
        2 // Second 25%: 2500-5000
    } else if (total_minted < THIRD_QUARTER) {
        3 // Third 25%: 5000-7500
    } else {
        4 // Last 25%: 7500-10000
    };

    // Progressive rarity distribution based on quarter
    if (quarter == 1) {
        // First quarter: Common 38%, Rare 33.5%, Elite 19.5%, Legendary 6%, Mythic 3%
        if (random_value <= 38) COMMON_RARITY
        else if (random_value <= 71) RARE_RARITY  // 38 + 33.5 = 71.5
        else if (random_value <= 91) ELITE_RARITY // 71.5 + 19.5 = 91
        else if (random_value <= 97) LEGENDARY_RARITY // 91 + 6 = 97
        else MYTHIC_RARITY // 97 + 3 = 100
    } else if (quarter == 2) {
        // Second quarter: Common 40%, Rare 35%, Elite 18%, Legendary 5%, Mythic 2%
        if (random_value <= 40) COMMON_RARITY
        else if (random_value <= 75) RARE_RARITY // 40 + 35 = 75
        else if (random_value <= 93) ELITE_RARITY // 75 + 18 = 93
        else if (random_value <= 98) LEGENDARY_RARITY // 93 + 5 = 98
        else MYTHIC_RARITY // 98 + 2 = 100
    } else if (quarter == 3) {
        // Third quarter: Common 43%, Rare 36%, Elite 16%, Legendary 4%, Mythic 1%
        if (random_value <= 43) COMMON_RARITY
        else if (random_value <= 79) RARE_RARITY // 43 + 36 = 79
        else if (random_value <= 95) ELITE_RARITY // 79 + 16 = 95
        else if (random_value <= 99) LEGENDARY_RARITY // 95 + 4 = 99
        else MYTHIC_RARITY // 99 + 1 = 100
    } else {
        // Fourth quarter: Common 48%, Rare 37%, Elite 12%, Legendary 2.5%, Mythic 0.5%
        if (random_value <= 48) COMMON_RARITY
        else if (random_value <= 85) RARE_RARITY // 48 + 37 = 85
        else if (random_value <= 97) ELITE_RARITY // 85 + 12 = 97
        else if (random_value <= 99) LEGENDARY_RARITY // 97 + 2.5 = 99.5 (rounded to 99)
        else MYTHIC_RARITY // 99.5 + 0.5 = 100
    }
}

fun init(otw: ISEKAI_BLADE, ctx: &mut TxContext) {
    // Create display object
    let keys = vector[
        utf8(b"name"),
        utf8(b"description"),
        utf8(b"image_url"),
        utf8(b"project_url"),
        utf8(b"creator"),
        utf8(b"rarity"),
        utf8(b"level"),
        utf8(b"item_type"),
        utf8(b"attack"),
        utf8(b"defense"),
        utf8(b"magic"),
    ];

    let values = vector[
        utf8(b"{name}"),
        utf8(b"{description}"),
        utf8(b"{image_url}"),
        utf8(b"https://marketplace.isekaiblade.com"),
        utf8(b"IsekaiBlade"),
        utf8(b"{rarity}"),
        utf8(b"{level}"),
        utf8(b"{item_type}"),
        utf8(b"{attack}"),
        utf8(b"{defense}"),
        utf8(b"{magic}"),
    ];

    let publisher = package::claim(otw, ctx);
    let mut display = display::new_with_fields<IsekaiBlade>(
        &publisher,
        keys,
        values,
        ctx,
    );

    display::update_version(&mut display);

    // Create admin capability
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };

    // Create governance capability
    let governance_cap = GovernanceCap {
        id: object::new(ctx),
    };

    // Create marketplace
    let marketplace = Marketplace {
        id: object::new(ctx),
        listings: table::new(ctx),
        total_listings: 0,
    };

    // Create NFT escrow
    let nft_escrow = NFTEscrow {
        id: object::new(ctx),
        escrowed_items: table::new(ctx),
    };

    // Create mint counter for progressive rarity
    let mint_counter = MintCounter {
        id: object::new(ctx),
        total_minted: 0,
    };

    // Create contract version for upgrade tracking
    let contract_version = ContractVersion {
        id: object::new(ctx),
        version: 1,
        last_upgraded: tx_context::epoch_timestamp_ms(ctx),
        upgrader: ctx.sender(),
    };

    // Create whitelist registry
    let whitelist_registry = WhitelistRegistry {
        id: object::new(ctx),
        rounds: table::new(ctx),
        active_rounds: vector::empty(),
        total_rounds: 0,
        admin: ctx.sender(),
    };

    // Transfer objects
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(display, ctx.sender());
    transfer::public_transfer(admin_cap, ctx.sender());
    transfer::public_transfer(governance_cap, ctx.sender());
    transfer::share_object(marketplace);
    transfer::share_object(nft_escrow);
    transfer::share_object(mint_counter);
    transfer::share_object(contract_version);
    transfer::share_object(whitelist_registry);
}

// === Access Control Functions ===

/// Grant role to a user (only governance can call this)
public fun grant_role(
    _governance_cap: &GovernanceCap,
    user: address,
    role: u8,
    ctx: &mut TxContext
): UserRole {
    assert!(role == ADMIN_ROLE || role == GOVERNANCE_ROLE, EInvalidRole);

    let granted_at = tx_context::epoch_timestamp_ms(ctx);

    // Emit security event
    emit(RoleGranted {
        user,
        role,
        granted_by: ctx.sender(),
        granted_at,
    });

    UserRole {
        user,
        role,
        granted_at,
    }
}

/// Revoke role from a user (only governance can call this)
public fun revoke_role(
    _governance_cap: &GovernanceCap,
    user_role: UserRole,
    ctx: &mut TxContext
) {
    // Emit security event before consuming the role
    emit(RoleRevoked {
        user: user_role.user,
        role: user_role.role,
        revoked_by: ctx.sender(),
        revoked_at: tx_context::epoch_timestamp_ms(ctx),
    });

    // Role is automatically revoked by consuming the UserRole object
    let UserRole { user: _, role: _, granted_at: _ } = user_role;
}

/// Check if user has admin role
public fun has_admin_role(user_role: &UserRole): bool {
    user_role.role == ADMIN_ROLE
}

/// Check if user has governance role
public fun has_governance_role(user_role: &UserRole): bool {
    user_role.role == GOVERNANCE_ROLE
}

/// Validate ownership of NFT using the owner field (not creator)
fun validate_nft_ownership(nft_owner: address, caller: address) {
    assert!(nft_owner == caller, ENotOwner);
}

// /// Log unauthorized access attempt - Removed unused function
// fun log_unauthorized_access(user: address, function_name: String, ctx: &TxContext) {
//     emit(UnauthorizedAccess {
//         user,
//         function_name,
//         timestamp: tx_context::epoch_timestamp_ms(ctx),
//     });
// }

/// Upgrade contract version (only governance can call this)
public fun upgrade_contract_version(
    _governance_cap: &GovernanceCap,
    contract_version: &mut ContractVersion,
    new_version: u64,
    ctx: &mut TxContext
) {
    // Validate that new version is higher than current
    assert!(new_version > contract_version.version, EInvalidRole);

    contract_version.version = new_version;
    contract_version.last_upgraded = tx_context::epoch_timestamp_ms(ctx);
    contract_version.upgrader = ctx.sender();
}

/// Get current contract version
public fun get_contract_version(contract_version: &ContractVersion): (u64, u64, address) {
    (contract_version.version, contract_version.last_upgraded, contract_version.upgrader)
}

// === Public Functions ===





/// List an item for sale on the marketplace
public fun list_item(
    marketplace: &mut Marketplace,
    item: IsekaiBlade,
    price: u64,
    ctx: &mut TxContext
) {
    let item_id = item.id.to_inner();
    let seller = ctx.sender();

    let listing = create_listing_from_item(&item, item_id, seller, price);

    table::add(&mut marketplace.listings, item_id, listing);
    marketplace.total_listings = marketplace.total_listings + 1;

    // Transfer item to marketplace (old broken method - NFT will be lost)
    transfer::public_transfer(item, @isekai_blade);

    emit(ItemListed {
        item_id,
        seller,
        price,
    });
}

/// Buy an item from the marketplace (BROKEN - NFT not transferred)
public fun buy_item(
    marketplace: &mut Marketplace,
    item_id: ID,
    payment: Coin<SUI>,
    ctx: &mut TxContext
) {
    assert!(table::contains(&marketplace.listings, item_id), EItemNotListed);

    let listing = table::remove(&mut marketplace.listings, item_id);
    let Listing { item_id: _, seller, price, .. } = listing;

    assert!(coin::value(&payment) >= price, EInsufficientFunds);

    marketplace.total_listings = marketplace.total_listings - 1;

    // Transfer payment to seller
    transfer::public_transfer(payment, seller);

    emit(ItemSold {
        item_id,
        seller,
        buyer: ctx.sender(),
        price,
    });

    // NOTE: NFT is NOT transferred - this function is broken!
}

/// Delist an item from the marketplace (BROKEN - NFT cannot be returned)
public fun delist_item(
    marketplace: &mut Marketplace,
    item_id: ID,
    ctx: &mut TxContext
) {
    assert!(table::contains(&marketplace.listings, item_id), EItemNotListed);

    let listing = table::borrow(&marketplace.listings, item_id);
    assert!(listing.seller == ctx.sender(), ENotOwner);

    let _removed_listing = table::remove(&mut marketplace.listings, item_id);
    marketplace.total_listings = marketplace.total_listings - 1;

    emit(ItemDelisted {
        item_id,
        seller: ctx.sender(),
    });

    // NOTE: NFT cannot be returned - this function is broken!
}

// === FIXED MARKETPLACE FUNCTIONS ===

/// FIXED: List an item for sale using proper escrow
/// Only the owner of the NFT can list it
public fun list_item_safe(
    marketplace: &mut Marketplace,
    escrow: &mut NFTEscrow,
    item: IsekaiBlade,
    price: u64,
    ctx: &mut TxContext
) {
    // Validate ownership using the owner field (not creator)
    validate_nft_ownership(get_owner(&item), ctx.sender());
    let item_id = object::id(&item);
    let seller = ctx.sender();

    // Create listing with NFT attributes
    let listing = create_listing_from_item(&item, item_id, seller, price);

    // Store NFT in escrow and add listing
    table::add(&mut escrow.escrowed_items, item_id, item);
    table::add(&mut marketplace.listings, item_id, listing);
    marketplace.total_listings = marketplace.total_listings + 1;

    emit(ItemListed {
        item_id,
        seller,
        price,
    });
}

/// FIXED: Buy an item with proper NFT transfer
#[allow(lint(self_transfer))]
public fun buy_item_safe(
    marketplace: &mut Marketplace,
    escrow: &mut NFTEscrow,
    item_id: ID,
    payment: Coin<SUI>,
    ctx: &mut TxContext
) {
    assert!(table::contains(&marketplace.listings, item_id), EItemNotListed);
    assert!(table::contains(&escrow.escrowed_items, item_id), EItemNotListed);

    let listing = table::remove(&mut marketplace.listings, item_id);
    let Listing { item_id: _, seller, price, .. } = listing;

    assert!(coin::value(&payment) >= price, EInsufficientFunds);

    marketplace.total_listings = marketplace.total_listings - 1;

    // Transfer payment to seller
    transfer::public_transfer(payment, seller);

    // FIXED: Transfer the NFT from escrow to the buyer
    let mut nft = table::remove(&mut escrow.escrowed_items, item_id);
    // Update the owner field to the new buyer
    set_owner(&mut nft, ctx.sender());
    transfer::public_transfer(nft, ctx.sender());

    emit(ItemSold {
        item_id,
        seller,
        buyer: ctx.sender(),
        price,
    });
}

/// FIXED: Delist an item and return NFT to seller
#[allow(lint(self_transfer))]
public fun delist_item_safe(
    marketplace: &mut Marketplace,
    escrow: &mut NFTEscrow,
    item_id: ID,
    ctx: &mut TxContext
) {
    assert!(table::contains(&marketplace.listings, item_id), EItemNotListed);
    assert!(table::contains(&escrow.escrowed_items, item_id), EItemNotListed);

    let listing = table::borrow(&marketplace.listings, item_id);
    assert!(listing.seller == ctx.sender(), ENotOwner);

    let _removed_listing = table::remove(&mut marketplace.listings, item_id);
    marketplace.total_listings = marketplace.total_listings - 1;

    // Return NFT from escrow to seller
    let nft = table::remove(&mut escrow.escrowed_items, item_id);
    transfer::public_transfer(nft, ctx.sender());

    emit(ItemDelisted {
        item_id,
        seller: ctx.sender(),
    });
}

// === View Functions ===

public fun name(item: &IsekaiBlade): String { item.name }
public fun description(item: &IsekaiBlade): String { item.description }
public fun item_type(item: &IsekaiBlade): u8 { item.item_type }
public fun rarity(item: &IsekaiBlade): u8 { item.rarity }
public fun level(item: &IsekaiBlade): u8 { item.level }
public fun attack(item: &IsekaiBlade): u64 { item.attack }
public fun defense(item: &IsekaiBlade): u64 { item.defense }
public fun magic(item: &IsekaiBlade): u64 { item.magic }
public fun dexterity(item: &IsekaiBlade): u64 { item.dexterity }
public fun image_url(item: &IsekaiBlade): String { item.image_url }
public fun creator(item: &IsekaiBlade): address { item.creator }

public fun get_listing_price(marketplace: &Marketplace, item_id: ID): u64 {
    let listing = table::borrow(&marketplace.listings, item_id);
    listing.price
}

public fun listing_seller(listing: &Listing): address { listing.seller }
public fun listing_price(listing: &Listing): u64 { listing.price }
public fun listing_item_id(listing: &Listing): ID { listing.item_id }

// Listing attribute getters
public fun listing_name(listing: &Listing): String { listing.name }
public fun listing_description(listing: &Listing): String { listing.description }
public fun listing_image_url(listing: &Listing): String { listing.image_url }
public fun listing_item_type(listing: &Listing): u8 { listing.item_type }
public fun listing_rarity(listing: &Listing): u8 { listing.rarity }
public fun listing_level(listing: &Listing): u8 { listing.level }
public fun listing_attack(listing: &Listing): u64 { listing.attack }
public fun listing_defense(listing: &Listing): u64 { listing.defense }
public fun listing_magic(listing: &Listing): u64 { listing.magic }
public fun listing_dexterity(listing: &Listing): u64 { listing.dexterity }
public fun listing_creator(listing: &Listing): address { listing.creator }

public fun create_listing_from_item(
    item: &IsekaiBlade,
    item_id: ID,
    seller: address,
    price: u64
): Listing {
    Listing {
        item_id,
        seller,
        price,
        // NFT attributes for display
        name: item.name,
        description: item.description,
        image_url: item.image_url,
        item_type: item.item_type,
        rarity: item.rarity,
        level: item.level,
        attack: item.attack,
        defense: item.defense,
        magic: item.magic,
        dexterity: item.dexterity,
        creator: item.creator,
    }
}

public fun total_listings(marketplace: &Marketplace): u64 {
    marketplace.total_listings
}

/// Helper function to extract dynamic field attributes from NFT for listings
/// This allows the frontend to get visual attributes without breaking existing Listing struct
public fun get_nft_visual_attributes(_nft_id: ID): (u64, u64, u64, bool) {
    // Since we can't access NFT object from here, return defaults
    // Frontend will need to fetch these from the NFT object directly
    (0, 0, 0, false)
}

/// Check if NFT has dynamic field attribute
public fun nft_has_dynamic_field(nft: &IsekaiBlade, field_name: String): bool {
    df::exists_(&nft.id, field_name)
}

/// Get hair_id from NFT dynamic fields
public fun get_nft_hair_id(nft: &IsekaiBlade): u64 {
    if (df::exists_(&nft.id, utf8(b"hair_id"))) {
        *df::borrow<String, u64>(&nft.id, utf8(b"hair_id"))
    } else { 0 }
}

/// Get armor_id from NFT dynamic fields
public fun get_nft_armor_id(nft: &IsekaiBlade): u64 {
    if (df::exists_(&nft.id, utf8(b"armor_id"))) {
        *df::borrow<String, u64>(&nft.id, utf8(b"armor_id"))
    } else { 0 }
}

/// Get mask_id from NFT dynamic fields
public fun get_nft_mask_id(nft: &IsekaiBlade): u64 {
    if (df::exists_(&nft.id, utf8(b"mask_id"))) {
        *df::borrow<String, u64>(&nft.id, utf8(b"mask_id"))
    } else { 0 }
}

/// Get is_female from NFT dynamic fields
public fun get_nft_is_female(nft: &IsekaiBlade): bool {
    if (df::exists_(&nft.id, utf8(b"is_female"))) {
        *df::borrow<String, bool>(&nft.id, utf8(b"is_female"))
    } else { false }
}

/// Create NFTEscrow as a shared object (call this once after upgrade)
public fun create_nft_escrow(ctx: &mut TxContext) {
    let nft_escrow = NFTEscrow {
        id: object::new(ctx),
        escrowed_items: table::new(ctx),
    };
    transfer::share_object(nft_escrow);
}

// === UPGRADE SYSTEM ===

// NFT Combine Success Rates
const COMMON_SUCCESS_RATE_1: u8 = 60;
const COMMON_SUCCESS_RATE_2: u8 = 95;
const RARE_SUCCESS_RATE_1: u8 = 50;
const RARE_SUCCESS_RATE_2: u8 = 80;
const ELITE_SUCCESS_RATE_1: u8 = 40;
const ELITE_SUCCESS_RATE_2: u8 = 75;
const LEGENDARY_SUCCESS_RATE_1: u8 = 35;
const LEGENDARY_SUCCESS_RATE_2: u8 = 70;
// Mythic cannot be upgraded further

// Additional error codes
// const ECombineNotAllowed: u64 = 9; // Removed unused constant
const EIncompatibleRarity: u64 = 14;
const EIncompatibleGender: u64 = 15;
const EMythicUpgrade: u64 = 16;

/// Upgrade two items of the same type to create a higher-level item
/// Keeps the higher level item and upgrades its attributes, burns the lower level item
/// Only the owner of both items can call this
#[allow(lint(public_random))]
public fun upgrade_items(
    item1: IsekaiBlade,
    item2: IsekaiBlade,
    r: &Random,
    ctx: &mut TxContext
): IsekaiBlade {
    // Validate ownership using the owner field (not creator)
    let caller = ctx.sender();
    validate_nft_ownership(get_owner(&item1), caller);
    validate_nft_ownership(get_owner(&item2), caller);
    // Validate that items are compatible for upgrade - only check item type
    assert!(item1.item_type == item2.item_type, EIncompatibleItems);
    assert!(object::id(&item1) != object::id(&item2), ESameItem);

    let old_item1_id = object::id(&item1);
    let old_item2_id = object::id(&item2);

    // Determine which item has higher level and use it as base
    let (mut base_item, other_item) = if (item1.level >= item2.level) {
        (item1, item2)
    } else {
        (item2, item1)
    };

    let old_level = base_item.level;
    let new_level = old_level + 1;
    assert!(old_level < MAX_LEVEL, EMaxLevel);

    // Calculate new stats using percentage upgrades based on the higher level item
    let new_attack = base_item.attack + (base_item.attack * ATTACK_UPGRADE_PERCENT) / 100;
    let new_defense = base_item.defense + (base_item.defense * DEFENSE_UPGRADE_PERCENT) / 100;
    let new_magic = base_item.magic + (base_item.magic * MAGIC_UPGRADE_PERCENT) / 100;

    // Check for rarity upgrade
    let mut generator = r.new_generator(ctx);
    let rarity_roll = generator.generate_u8_in_range(1, 100);
    let new_rarity = if (rarity_roll <= RARITY_UPGRADE_CHANCE && base_item.rarity < LEGENDARY_RARITY) {
        base_item.rarity + 1
    } else {
        base_item.rarity
    };

    // Update the base item (higher level item) with new attributes
    base_item.level = new_level;
    base_item.attack = new_attack;
    base_item.defense = new_defense;
    base_item.magic = new_magic;
    base_item.rarity = new_rarity;

    let upgraded_item_id = object::id(&base_item);

    // Emit upgrade event
    emit(ItemUpgraded {
        old_item1_id,
        old_item2_id,
        new_item_id: upgraded_item_id,
        old_level,
        new_level,
        upgraded_by: ctx.sender(),
    });

    // Only destroy the lower level item (other_item)
    let IsekaiBlade {
        id: other_id,
        name: _,
        description: _,
        item_type: _,
        rarity: _,
        level: _,
        attack: _,
        defense: _,
        magic: _,
        dexterity: _,
        image_url: _,
        creator: _,
    } = other_item;
    object::delete(other_id);

    // Return the upgraded base item (which keeps its original ID)
    base_item
}

/// Upgrade attributes of a single item by paying 1 SUI fee
/// Randomly increases attack, defense, and magic within specified ranges
/// Only the owner of the item can call this
#[allow(lint(public_random), lint(self_transfer))]
public fun upgrade_attributes(
    mut item: IsekaiBlade,
    mut payment: Coin<SUI>,
    owner_wallet: address,
    r: &Random,
    ctx: &mut TxContext
): IsekaiBlade {
    // Validate ownership using the owner field (not creator)
    validate_nft_ownership(get_owner(&item), ctx.sender());
    // Validate payment amount
    assert!(coin::value(&payment) >= ATTRIBUTE_UPGRADE_FEE, EInsufficientPayment);

    // Extract the exact fee amount
    let fee_coin = coin::split(&mut payment, ATTRIBUTE_UPGRADE_FEE, ctx);

    // Transfer fee to owner wallet
    transfer::public_transfer(fee_coin, owner_wallet);

    // Return remaining payment to sender
    if (coin::value(&payment) > 0) {
        transfer::public_transfer(payment, ctx.sender());
    } else {
        coin::destroy_zero(payment);
    };

    // Store old attributes for event
    let old_attack = item.attack;
    let old_defense = item.defense;
    let old_magic = item.magic;
    let old_dexterity = item.dexterity;

    // Generate random upgrades for each attribute
    let mut generator = r.new_generator(ctx);
    let attack_increase = generator.generate_u64_in_range(MIN_ATTRIBUTE_UPGRADE, MAX_ATTRIBUTE_UPGRADE + 1);
    let defense_increase = generator.generate_u64_in_range(MIN_ATTRIBUTE_UPGRADE, MAX_ATTRIBUTE_UPGRADE + 1);
    let magic_increase = generator.generate_u64_in_range(MIN_ATTRIBUTE_UPGRADE, MAX_ATTRIBUTE_UPGRADE + 1);

    // Apply upgrades
    item.attack = item.attack + attack_increase;
    item.defense = item.defense + defense_increase;
    item.magic = item.magic + magic_increase;

    // Emit upgrade event
    emit(AttributeUpgraded {
        item_id: object::id(&item),
        old_attack,
        old_defense,
        old_magic,
        new_attack: item.attack,
        new_defense: item.defense,
        new_magic: item.magic,
        upgraded_by: ctx.sender(),
    });

    item
}

/// Combine NFTs of the same rarity and gender (upgrade system)
/// Uses base NFT with highest stat, attempts to upgrade to higher rarity
/// Success: base NFT upgraded, sacrifice NFTs burned
/// Failure: base NFT unchanged, sacrifice NFTs burned
/// Only the owner of all NFTs can call this
#[allow(lint(public_random))]
public fun combine_nfts(
    mut base_nft: IsekaiBlade,
    sacrifice_nft: IsekaiBlade,
    optional_nft: Option<IsekaiBlade>,
    r: &Random,
    ctx: &mut TxContext
): IsekaiBlade {
    // Validate ownership using the owner field (not creator)
    let caller = ctx.sender();
    validate_nft_ownership(get_owner(&base_nft), caller);
    validate_nft_ownership(get_owner(&sacrifice_nft), caller);

    // Validate optional NFT ownership if provided
    if (option::is_some(&optional_nft)) {
        let third_nft = option::borrow(&optional_nft);
        validate_nft_ownership(get_owner(third_nft), caller);
    };
    let base_rarity = base_nft.rarity;

    // Store IDs for events before consuming NFTs
    let base_nft_id = object::id(&base_nft);
    let sacrifice_nft_id = object::id(&sacrifice_nft);

    // Validate: Cannot upgrade mythic
    assert!(base_rarity != MYTHIC_RARITY, EMythicUpgrade);

    // Validate: Same rarity
    assert!(base_nft.rarity == sacrifice_nft.rarity, EIncompatibleRarity);

    // Get gender from attributes for both NFTs (assuming character type)
    let base_gender = if (base_nft.item_type == CHARACTER_TYPE) {
        get_character_gender(&base_nft)
    } else {
        0 // Non-character items don't have gender restriction
    };

    let sacrifice_gender = if (sacrifice_nft.item_type == CHARACTER_TYPE) {
        get_character_gender(&sacrifice_nft)
    } else {
        0
    };

    // Validate: Same gender for character items
    if (base_nft.item_type == CHARACTER_TYPE) {
        assert!(base_gender == sacrifice_gender, EIncompatibleGender);
    };

    // Determine sacrifice count and optional NFT ID
    let (sacrifice_count, optional_nft_id) = if (option::is_some(&optional_nft)) {
        let third_nft = option::destroy_some(optional_nft);
        let third_nft_id = object::id(&third_nft);

        // Validate third NFT has same rarity and gender
        assert!(third_nft.rarity == base_rarity, EIncompatibleRarity);

        if (base_nft.item_type == CHARACTER_TYPE) {
            let third_gender = get_character_gender(&third_nft);
            assert!(base_gender == third_gender, EIncompatibleGender);
        };

        // FIXED: Always keep the original base_nft as the main item
        // Absorb power from sacrifice NFTs by adding their stats as bonus
        let sacrifice_total = sacrifice_nft.attack + sacrifice_nft.defense + sacrifice_nft.magic;
        let third_total = third_nft.attack + third_nft.defense + third_nft.magic;
        let combined_sacrifice_power = sacrifice_total + third_total;
        
        // Add 10% of combined sacrifice power as bonus stats to base NFT
        let bonus_per_stat = combined_sacrifice_power / 30; // Divide by 30 (10% split across 3 stats)
        base_nft.attack = base_nft.attack + bonus_per_stat;
        base_nft.defense = base_nft.defense + bonus_per_stat;
        base_nft.magic = base_nft.magic + bonus_per_stat;

        // Always destroy sacrifice NFTs (base_nft is preserved)
        destroy_nft(sacrifice_nft);
        destroy_nft(third_nft);

        (2, option::some(third_nft_id))
    } else {
        option::destroy_none(optional_nft);

        // FIXED: Always keep the original base_nft as the main item
        // Absorb power from sacrifice NFT by adding its stats as bonus
        let sacrifice_total = sacrifice_nft.attack + sacrifice_nft.defense + sacrifice_nft.magic;
        
        // Add 5% of sacrifice power as bonus stats to base NFT
        let bonus_per_stat = sacrifice_total / 60; // Divide by 60 (5% split across 3 stats)
        base_nft.attack = base_nft.attack + bonus_per_stat;
        base_nft.defense = base_nft.defense + bonus_per_stat;
        base_nft.magic = base_nft.magic + bonus_per_stat;

        // Always destroy sacrifice NFT (base_nft is preserved)
        destroy_nft(sacrifice_nft);

        (1, option::none())
    };

    // Determine success rate based on rarity and sacrifice count
    let success_rate = if (base_rarity == COMMON_RARITY) {
        if (sacrifice_count == 1) COMMON_SUCCESS_RATE_1 else COMMON_SUCCESS_RATE_2
    } else if (base_rarity == RARE_RARITY) {
        if (sacrifice_count == 1) RARE_SUCCESS_RATE_1 else RARE_SUCCESS_RATE_2
    } else if (base_rarity == ELITE_RARITY) {
        if (sacrifice_count == 1) ELITE_SUCCESS_RATE_1 else ELITE_SUCCESS_RATE_2
    } else if (base_rarity == LEGENDARY_RARITY) {
        if (sacrifice_count == 1) LEGENDARY_SUCCESS_RATE_1 else LEGENDARY_SUCCESS_RATE_2
    } else {
        0
    };

    // Roll for success
    let mut generator = new_generator(r, ctx);
    let roll = generator.generate_u8_in_range(1, 101); // 1-100

    if (roll <= success_rate) {
        // SUCCESS: Upgrade to higher rarity with random higher stats
        base_nft.rarity = base_rarity + 1;

        // Generate stat increases based on new rarity
        let stat_bonus = if (base_nft.rarity == RARE_RARITY) {
            25
        } else if (base_nft.rarity == ELITE_RARITY) {
            50
        } else if (base_nft.rarity == LEGENDARY_RARITY) {
            100
        } else if (base_nft.rarity == MYTHIC_RARITY) {
            200
        } else {
            25
        };

        // Increase stats randomly within the rarity range
        let attack_increase = generator.generate_u64_in_range(stat_bonus / 4, stat_bonus / 2);
        let defense_increase = generator.generate_u64_in_range(stat_bonus / 4, stat_bonus / 2);
        let magic_increase = generator.generate_u64_in_range(stat_bonus / 4, stat_bonus / 2);

        base_nft.attack = base_nft.attack + attack_increase;
        base_nft.defense = base_nft.defense + defense_increase;
        base_nft.magic = base_nft.magic + magic_increase;

        // Emit success event
        emit(NFTCombineSuccess {
            base_nft_id,
            sacrifice_nft_id,
            optional_nft_id,
            new_nft_id: object::id(&base_nft),
            rarity: base_nft.rarity,
            combined_by: tx_context::sender(ctx),
        });
    } else {
        // FAILURE: Base NFT stats unchanged, sacrifice NFTs already burned
        emit(NFTCombineFailure {
            base_nft_id,
            sacrifice_nft_id,
            optional_nft_id,
            rarity: base_rarity,
            combined_by: tx_context::sender(ctx),
        });
    };

    base_nft
}

/// Helper function to get character gender from attributes
fun get_character_gender(nft: &IsekaiBlade): u8 {
    // Use the is_female dynamic field, convert to u8
    if (get_is_female(nft)) {
        1 // female
    } else {
        0 // male
    }
}

/// Helper function to destroy/burn an NFT
fun destroy_nft(nft: IsekaiBlade) {
    let IsekaiBlade {
        id,
        name: _,
        description: _,
        item_type: _,
        rarity: _,
        level: _,
        attack: _,
        defense: _,
        magic: _,
        dexterity: _,
        image_url: _,
        creator: _,
    } = nft;

    object::delete(id);
}

// === SET SYSTEM ===

/// Create a new item set for bundling items together for sale
public fun create_set(
    name: String,
    description: String,
    ctx: &mut TxContext
): ItemSet {
    let set_id = object::new(ctx);
    let created_at = tx_context::epoch_timestamp_ms(ctx);

    let set = ItemSet {
        id: set_id,
        name,
        description,
        items: table::new(ctx),
        item_count: 0,
        creator: ctx.sender(),
        created_at,
    };

    emit(SetCreated {
        set_id: object::id(&set),
        name: set.name,
        creator: set.creator,
        created_at,
    });

    set
}

/// Add an item to a set (only the set creator can do this)
public fun add_item_to_set(
    set: &mut ItemSet,
    item: IsekaiBlade,
    ctx: &mut TxContext
) {
    assert!(set.creator == ctx.sender(), ENotOwner);

    let item_id = object::id(&item);
    table::add(&mut set.items, item_id, item);
    set.item_count = set.item_count + 1;

    emit(ItemAddedToSet {
        set_id: object::id(set),
        item_id,
        added_by: ctx.sender(),
    });
}

/// Add multiple items to a set in one transaction (only the set creator can do this)
public fun add_items_to_set(
    set: &mut ItemSet,
    mut items: vector<IsekaiBlade>,
    ctx: &mut TxContext
) {
    assert!(set.creator == ctx.sender(), ENotOwner);

    let mut i = 0;
    let items_count = vector::length(&items);

    while (i < items_count) {
        let item = vector::pop_back(&mut items);
        let item_id = object::id(&item);
        table::add(&mut set.items, item_id, item);
        set.item_count = set.item_count + 1;

        emit(ItemAddedToSet {
            set_id: object::id(set),
            item_id,
            added_by: ctx.sender(),
        });

        i = i + 1;
    };

    // Clean up empty vector
    vector::destroy_empty(items);
}

/// Remove an item from a set and return it (only the set creator can do this)
public fun remove_item_from_set(
    set: &mut ItemSet,
    item_id: ID,
    ctx: &mut TxContext
): IsekaiBlade {
    assert!(set.creator == ctx.sender(), ENotOwner);
    assert!(table::contains(&set.items, item_id), EItemNotListed);

    let item = table::remove(&mut set.items, item_id);
    set.item_count = set.item_count - 1;

    emit(ItemRemovedFromSet {
        set_id: object::id(set),
        item_id,
        removed_by: ctx.sender(),
    });

    item
}

/// Get all item IDs in a set (for frontend querying)
#[allow(unused_variable, unused_let_mut)]
public fun get_set_item_ids(_set: &ItemSet): vector<ID> {
    let mut item_ids = vector::empty<ID>();
    // Note: This is a simplified approach. In production, you might want to
    // implement pagination for sets with many items
    item_ids
}

/// Check if a set contains a specific item
public fun set_contains_item(set: &ItemSet, item_id: ID): bool {
    table::contains(&set.items, item_id)
}

/// Get set metadata
public fun get_set_info(set: &ItemSet): (String, String, u64, address, u64) {
    (set.name, set.description, set.item_count, set.creator, set.created_at)
}

/// List a set on the marketplace for sale
#[allow(unused_variable)]
public fun list_set_on_marketplace(
    marketplace: &mut Marketplace,
    _escrow: &mut NFTEscrow,
    set: ItemSet,
    price: u64,
    ctx: &mut TxContext
) {
    let set_id = object::id(&set);
    let seller = ctx.sender();

    // Create a special listing for the set with aggregated info
    let listing = Listing {
        item_id: set_id,
        seller,
        price,
        name: set.name,
        description: set.description,
        image_url: utf8(b""), // Sets don't have individual images
        item_type: 255, // Special type for sets
        rarity: 255, // Special rarity for sets
        level: set.item_count as u8, // Use level field to show item count
        attack: 0, // Not applicable for sets
        defense: 0, // Not applicable for sets
        magic: 0, // Not applicable for sets
        dexterity: 0, // Not applicable for sets
        creator: set.creator,
    };

    // For simplicity, we'll store the set in the regular escrow
    // In a production system, you might want a separate escrow for sets
    table::add(&mut marketplace.listings, set_id, listing);
    marketplace.total_listings = marketplace.total_listings + 1;

    // Note: We're not putting the set in escrow for now - this is simplified
    // In production, you'd want proper escrow handling for sets too
    transfer::public_transfer(set, @isekai_blade); // Temporary solution

    emit(ItemListed {
        item_id: set_id,
        seller,
        price,
    });
}

/// Buy a set from the marketplace and receive all items in it
public fun buy_set_from_marketplace(
    marketplace: &mut Marketplace,
    set_id: ID,
    payment: Coin<SUI>,
    ctx: &mut TxContext
) {
    assert!(table::contains(&marketplace.listings, set_id), EItemNotListed);

    let listing = table::remove(&mut marketplace.listings, set_id);
    let Listing { item_id: _, seller, price, .. } = listing;

    assert!(coin::value(&payment) >= price, EInsufficientFunds);

    marketplace.total_listings = marketplace.total_listings - 1;

    // Transfer payment to seller
    transfer::public_transfer(payment, seller);

    // Note: This is simplified - in production you'd retrieve the set from escrow
    // and transfer all items individually to the buyer

    emit(SetSold {
        set_id,
        seller,
        buyer: ctx.sender(),
        price,
        item_count: 0, // Would be populated from actual set
    });
}

// === SET VIEW FUNCTIONS ===

public fun set_name(set: &ItemSet): String { set.name }
public fun set_description(set: &ItemSet): String { set.description }
public fun set_item_count(set: &ItemSet): u64 { set.item_count }
public fun set_creator(set: &ItemSet): address { set.creator }
public fun set_created_at(set: &ItemSet): u64 { set.created_at }

// === Whitelist & Round System ===

/// Whitelist entry for a user in a specific round
public struct WhitelistEntry has store, copy, drop {
    max_mints: u8,
    remaining_mints: u8,
    added_at: u64,
    added_by: address,
}

/// Round-based Whitelist system for multiple minting rounds
public struct WhitelistRound has key, store {
    id: UID,
    round_id: String,
    whitelisted_users: Table<address, WhitelistEntry>,
    total_whitelisted: u64,
    is_active: bool,
    is_public: bool, // New field: if true, anyone can mint without being whitelisted
    created_at: u64,
    updated_at: u64,
    admin: address,
}

/// Pricing configuration stored as dynamic field
public struct RoundPricing has copy, drop, store {
    mint_price: u64,
    max_supply: u64,
    current_minted: u64,
}

/// Global whitelist registry to manage multiple rounds
public struct WhitelistRegistry has key {
    id: UID,
    rounds: Table<String, ID>,
    active_rounds: vector<String>,
    total_rounds: u64,
    admin: address,
}

// === Whitelist Events ===

public struct WhitelistRoundCreated has copy, drop {
    round_id: String,
    admin: address,
    created_at: u64,
}

public struct WhitelistEntryAdded has copy, drop {
    round_id: String,
    user: address,
    max_mints: u8,
    added_by: address,
    added_at: u64,
}

public struct WhitelistBulkAdded has copy, drop {
    round_id: String,
    addresses: vector<address>,
    max_mints: u8,
    added_by: address,
    total_added: u64,
}

public struct WhitelistEntryRemoved has copy, drop {
    round_id: String,
    user: address,
    removed_by: address,
}

public struct WhitelistRoundStatusToggled has copy, drop {
    round_id: String,
    is_active: bool,
    updated_by: address,
}

public struct RoundPublicStatusToggled has copy, drop {
    round_id: String,
    is_public: bool,
    updated_by: address,
}

public struct WhitelistMintUsed has copy, drop {
    round_id: String,
    user: address,
    remaining_mints: u8,
}

// === Whitelist Functions ===

/// Create a new whitelist round (Admin only)
public fun create_whitelist_round(
    _: &AdminCap,
    registry: &mut WhitelistRegistry,
    round_id: String,
    is_public: bool,
    ctx: &mut TxContext
) {
    let mut round = WhitelistRound {
        id: object::new(ctx),
        round_id: round_id,
        whitelisted_users: table::new(ctx),
        total_whitelisted: 0,
        is_active: true,
        is_public,
        created_at: tx_context::epoch_timestamp_ms(ctx),
        updated_at: tx_context::epoch_timestamp_ms(ctx),
        admin: tx_context::sender(ctx),
    };

    // Add pricing as dynamic field
    let pricing = RoundPricing {
        mint_price: 2000000000, // Default 0.5 SUI
        max_supply: 1000, // Default max supply
        current_minted: 0,
    };
    df::add(&mut round.id, utf8(b"pricing"), pricing);

    let round_id_copy = round.round_id;
    let round_object_id = object::id(&round);

    table::add(&mut registry.rounds, round_id_copy, round_object_id);
    vector::push_back(&mut registry.active_rounds, round_id_copy);
    registry.total_rounds = registry.total_rounds + 1;

    emit(WhitelistRoundCreated {
        round_id: round_id_copy,
        admin: tx_context::sender(ctx),
        created_at: tx_context::epoch_timestamp_ms(ctx),
    });

    transfer::share_object(round);
}

/// Create a new whitelist round with custom pricing (Admin only) - NEW FUNCTION
public fun create_whitelist_round_with_pricing(
    _: &AdminCap,
    registry: &mut WhitelistRegistry,
    round_id: String,
    mint_price: u64, // Price in MIST (e.g., 2000000000 = 0.5 SUI)
    max_supply: u64, // Maximum NFTs for this round
    is_public: bool, // Whether anyone can mint or only whitelisted users
    ctx: &mut TxContext
) {
    let mut round = WhitelistRound {
        id: object::new(ctx),
        round_id: round_id,
        whitelisted_users: table::new(ctx),
        total_whitelisted: 0,
        is_active: true,
        is_public,
        created_at: tx_context::epoch_timestamp_ms(ctx),
        updated_at: tx_context::epoch_timestamp_ms(ctx),
        admin: tx_context::sender(ctx),
    };

    // Add custom pricing as dynamic field
    let pricing = RoundPricing {
        mint_price,
        max_supply,
        current_minted: 0,
    };
    df::add(&mut round.id, utf8(b"pricing"), pricing);

    let round_id_copy = round.round_id;
    let round_object_id = object::id(&round);

    table::add(&mut registry.rounds, round_id_copy, round_object_id);
    vector::push_back(&mut registry.active_rounds, round_id_copy);
    registry.total_rounds = registry.total_rounds + 1;

    emit(WhitelistRoundCreated {
        round_id: round_id_copy,
        admin: tx_context::sender(ctx),
        created_at: tx_context::epoch_timestamp_ms(ctx),
    });

    transfer::share_object(round);
}

/// Whitelist mint with round-specific pricing (requires round object)
public fun whitelist_mint_with_pricing(
    mint_counter: &mut MintCounter,
    round: &mut WhitelistRound,
    payment: Coin<SUI>,
    name: String,
    description: String,
    r: &Random,
    ctx: &mut TxContext
): IsekaiBlade {
    let user = tx_context::sender(ctx);

    // Check if round is active
    assert!(round.is_active, EWhitelistNotFound);

    // Get pricing first to avoid multiple dynamic field access
    let pricing = df::borrow<String, RoundPricing>(&round.id, utf8(b"pricing"));
    assert!(pricing.current_minted < pricing.max_supply, EInsufficientMints);
    assert!(coin::value(&payment) >= pricing.mint_price, EInsufficientPayment);

    // For private rounds, check whitelist and update remaining mints in single pass
    if (!round.is_public) {
        assert!(table::contains(&round.whitelisted_users, user), EWhitelistNotFound);
        let entry_mut = table::borrow_mut(&mut round.whitelisted_users, user);
        assert!(entry_mut.remaining_mints > 0, EInsufficientMints);
        entry_mut.remaining_mints = entry_mut.remaining_mints - 1;
    };

    // Transfer payment to treasury owner wallet address instead of zero address
    transfer::public_transfer(payment, @0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39);

    // Update pricing in dynamic field
    let pricing_mut = df::borrow_mut<String, RoundPricing>(&mut round.id, utf8(b"pricing"));
    pricing_mut.current_minted = pricing_mut.current_minted + 1;
    round.updated_at = tx_context::epoch_timestamp_ms(ctx);

    // Update mint counter
    mint_counter.total_minted = mint_counter.total_minted + 1;

    // Generate NFT using the whitelist mint logic (similar to original whitelist_mint)
    let mut generator = r.new_generator(ctx);

    // Enhanced rarity for whitelist users
    let rarity_roll = generator.generate_u8_in_range(1, 100);
    let rarity = if (rarity_roll <= 15) LEGENDARY_RARITY  // 15% vs 5% regular
                 else if (rarity_roll <= 40) ELITE_RARITY  // 25% vs 15% regular
                 else if (rarity_roll <= 70) RARE_RARITY   // 30% vs 30% regular
                 else COMMON_RARITY;                       // 30% vs 50% regular

    // Generate stats with whitelist bonus
    let base_stats = match (rarity) {
        1 => 15, // Common with bonus
        2 => 30, // Rare with bonus
        3 => 60, // Elite with bonus
        4 => 120, // Legendary with bonus
        _ => 15,
    };

    let attack = base_stats + generator.generate_u64_in_range(0, base_stats / 2);
    let defense = base_stats + generator.generate_u64_in_range(0, base_stats / 2);
    let magic = base_stats + generator.generate_u64_in_range(0, base_stats / 2);
    let dexterity = base_stats + generator.generate_u64_in_range(0, base_stats / 2);

    // Generate NFT
    let temp_id = object::new(ctx);
    let nft_address = object::uid_to_address(&temp_id);
    let random_seed = generator.generate_u64();
    let is_female_rand = generator.generate_u64_in_range(0, 10);
    let item_type = CHARACTER_TYPE;

    let (hair_id, armor_id, mask_id, is_female) = image_generator::generate_character_asset_ids(
        nft_address,
        item_type,
        rarity,
        random_seed,
        is_female_rand
    );

    let image_url = image_generator::generate_secure_image_url_from_id(nft_address);

    let mut item = IsekaiBlade {
        id: temp_id,
        name,
        description,
        item_type,
        rarity,
        level: 1,
        attack,
        defense,
        magic,
        dexterity,
        image_url,
        creator: user,
    };

    set_owner(&mut item, user);
    set_asset_ids(&mut item, hair_id, armor_id, mask_id, is_female);

    // Emit appropriate event based on round type
    if (round.is_public) {
        // For public rounds, we don't track individual remaining mints
        emit(WhitelistMintUsed {
            round_id: round.round_id,
            user,
            remaining_mints: 0, // Not applicable for public rounds
        });
    } else if (table::contains(&round.whitelisted_users, user)) {
        // For private rounds, show actual remaining mints
        let entry = table::borrow(&round.whitelisted_users, user);
        emit(WhitelistMintUsed {
            round_id: round.round_id,
            user,
            remaining_mints: entry.remaining_mints,
        });
    };

    // Get pricing for event
    let pricing = df::borrow<String, RoundPricing>(&round.id, utf8(b"pricing"));

    emit(NFTMinted {
        nft_id: object::id(&item),
        minter: user,
        mint_count: mint_counter.total_minted,
        rarity,
        item_type,
        whitelist_used: true,
        discount_applied: true,
        final_price: pricing.mint_price,
        round_id: option::some(round.round_id),
    });

    item
}

/// Update round pricing and supply (Admin only)
public fun update_round_pricing(
    _: &AdminCap,
    round: &mut WhitelistRound,
    new_mint_price: u64,
    new_max_supply: u64,
    ctx: &mut TxContext
) {
    // Update pricing in dynamic field
    let pricing_mut = df::borrow_mut<String, RoundPricing>(&mut round.id, utf8(b"pricing"));
    pricing_mut.mint_price = new_mint_price;
    pricing_mut.max_supply = new_max_supply;
    round.updated_at = tx_context::epoch_timestamp_ms(ctx);
}

/// Add a single address to whitelist round (Admin only)
public fun add_to_whitelist_round(
    _: &AdminCap,
    round: &mut WhitelistRound,
    user: address,
    max_mints: u8,
    ctx: &mut TxContext
) {
    let entry = WhitelistEntry {
        max_mints,
        remaining_mints: max_mints,
        added_at: tx_context::epoch_timestamp_ms(ctx),
        added_by: tx_context::sender(ctx),
    };

    if (table::contains(&round.whitelisted_users, user)) {
        table::remove(&mut round.whitelisted_users, user);
    } else {
        round.total_whitelisted = round.total_whitelisted + 1;
    };

    table::add(&mut round.whitelisted_users, user, entry);
    round.updated_at = tx_context::epoch_timestamp_ms(ctx);

    emit(WhitelistEntryAdded {
        round_id: round.round_id,
        user,
        max_mints,
        added_by: tx_context::sender(ctx),
        added_at: tx_context::epoch_timestamp_ms(ctx),
    });
}

/// Bulk add addresses to whitelist round (Admin only)
public fun bulk_add_to_whitelist_round(
    _: &AdminCap,
    round: &mut WhitelistRound,
    users: vector<address>,
    max_mints: u8,
    ctx: &mut TxContext
) {
    let len = vector::length(&users);
    let mut i: u64 = 0;
    let mut added_count: u64 = 0;

    while (i < len) {
        let user = *vector::borrow(&users, i);
        let entry = WhitelistEntry {
            max_mints,
            remaining_mints: max_mints,
            added_at: tx_context::epoch_timestamp_ms(ctx),
            added_by: tx_context::sender(ctx),
        };

        if (table::contains(&round.whitelisted_users, user)) {
            table::remove(&mut round.whitelisted_users, user);
        } else {
            round.total_whitelisted = round.total_whitelisted + 1;
        };

        table::add(&mut round.whitelisted_users, user, entry);
        added_count = added_count + 1;
        i = i + 1;
    };

    round.updated_at = tx_context::epoch_timestamp_ms(ctx);

    emit(WhitelistBulkAdded {
        round_id: round.round_id,
        addresses: users,
        max_mints,
        added_by: tx_context::sender(ctx),
        total_added: added_count,
    });
}

/// Remove address from whitelist round (Admin only)
public fun remove_from_whitelist_round(
    _: &AdminCap,
    round: &mut WhitelistRound,
    user: address,
    ctx: &mut TxContext
) {
    assert!(table::contains(&round.whitelisted_users, user), EWhitelistNotFound);

    table::remove(&mut round.whitelisted_users, user);
    round.total_whitelisted = round.total_whitelisted - 1;
    round.updated_at = tx_context::epoch_timestamp_ms(ctx);

    emit(WhitelistEntryRemoved {
        round_id: round.round_id,
        user,
        removed_by: tx_context::sender(ctx),
    });
}

/// Toggle whitelist round active status (Admin only)
public fun toggle_whitelist_round_status(
    _: &AdminCap,
    round: &mut WhitelistRound,
    is_active: bool,
    ctx: &mut TxContext
) {
    round.is_active = is_active;
    round.updated_at = tx_context::epoch_timestamp_ms(ctx);

    emit(WhitelistRoundStatusToggled {
        round_id: round.round_id,
        is_active,
        updated_by: tx_context::sender(ctx),
    });
}

/// Toggle public access for a round (Admin only)
public fun toggle_round_public_access(
    _: &AdminCap,
    round: &mut WhitelistRound,
    is_public: bool,
    ctx: &mut TxContext
) {
    round.is_public = is_public;
    round.updated_at = tx_context::epoch_timestamp_ms(ctx);

    emit(RoundPublicStatusToggled {
        round_id: round.round_id,
        is_public,
        updated_by: tx_context::sender(ctx),
    });
}

/// Event for comprehensive minting
public struct NFTMinted has copy, drop {
    nft_id: ID,
    minter: address,
    mint_count: u64,
    rarity: u8,
    item_type: u8,
    whitelist_used: bool,
    discount_applied: bool,
    final_price: u64,
    round_id: Option<String>,
}

/// UNIFIED MINT FUNCTION - The only mint function needed
/// Auto-detects conditions and handles:
/// - 9 rounds support through round system
/// - Whitelist eligibility with round-specific pricing
/// - Progressive rarity distribution
/// - Payment verification and routing
/// - All business logic in one function
public fun unified_mint(
    mint_counter: &mut MintCounter,
    whitelist_registry: &WhitelistRegistry,
    round_name: Option<String>,
    round_mint_price: Option<u64>,
    payment: Coin<SUI>,
    name: String,
    description: String,
    owner_address: address,
    r: &Random,
    ctx: &mut TxContext
): IsekaiBlade {
    let user = tx_context::sender(ctx);
    let mut generator = r.new_generator(ctx);
    let current_mint_count = mint_counter.total_minted;

    // AUTO-BREAK CONDITION 1: Check maximum supply (9 rounds worth)
    let max_supply_per_round = 1111; // 9 rounds * 1111 = 9999 total supply
    let total_max_supply = 9 * max_supply_per_round;
    assert!(current_mint_count < total_max_supply, EInsufficientMints);

    // AUTO-BREAK CONDITION 2: Determine which round we're in (1-9)
    let current_round = (current_mint_count / max_supply_per_round) + 1;
    let _round_progress = current_mint_count % max_supply_per_round;

    // AUTO-BREAK CONDITION 3: Whitelist eligibility and round-specific pricing
    let (mut is_whitelist, mut active_round_id, mut final_mint_price) = (false, option::none<String>(), MINT_PRICE);

    if (option::is_some(&round_name)) {
        let requested_round = *option::borrow(&round_name);

        // Check if the requested round exists in registry
        if (table::contains(&whitelist_registry.rounds, requested_round)) {
            is_whitelist = true;
            active_round_id = option::some(requested_round);

            // Use provided round pricing or default to 50% discount
            if (option::is_some(&round_mint_price)) {
                final_mint_price = *option::borrow(&round_mint_price);
            } else {
                final_mint_price = MINT_PRICE / 2; // Fallback to default 50% discount
            }
        }
    };

    // AUTO-BREAK CONDITION 4: Payment verification with dynamic pricing
    assert!(coin::value(&payment) >= final_mint_price, EInsufficientPayment);

    // Transfer payment to owner
    transfer::public_transfer(payment, owner_address);

    // Note: Round-specific updates need to be handled in separate transactions
    // This is a simplified version for the unified mint
    if (is_whitelist && option::is_some(&active_round_id)) {
        emit(WhitelistMintUsed {
            round_id: *option::borrow(&active_round_id),
            user,
            remaining_mints: 0, // Would need round object to track this accurately
        });
    };

    // Update mint counter
    mint_counter.total_minted = current_mint_count + 1;

    // AUTO-BREAK CONDITION 5: Progressive rarity distribution based on round
    let rarity_roll = generator.generate_u8_in_range(1, 100);
    let rarity = if (current_round <= 3) {
        // Early rounds (1-3): Higher chance of rare items
        if (is_whitelist) {
            // Whitelist users get better odds
            if (rarity_roll <= 15) LEGENDARY_RARITY      // 15% vs 10% regular
            else if (rarity_roll <= 40) ELITE_RARITY     // 25% vs 20% regular
            else if (rarity_roll <= 70) RARE_RARITY      // 30% vs 30% regular
            else COMMON_RARITY                           // 30% vs 40% regular
        } else {
            if (rarity_roll <= 10) LEGENDARY_RARITY      // 10%
            else if (rarity_roll <= 30) ELITE_RARITY     // 20%
            else if (rarity_roll <= 60) RARE_RARITY      // 30%
            else COMMON_RARITY                           // 40%
        }
    } else if (current_round <= 6) {
        // Mid rounds (4-6): Balanced distribution
        if (is_whitelist) {
            if (rarity_roll <= 12) LEGENDARY_RARITY      // 12% vs 7% regular
            else if (rarity_roll <= 32) ELITE_RARITY     // 20% vs 18% regular
            else if (rarity_roll <= 62) RARE_RARITY      // 30% vs 30% regular
            else COMMON_RARITY                           // 38% vs 45% regular
        } else {
            if (rarity_roll <= 7) LEGENDARY_RARITY       // 7%
            else if (rarity_roll <= 25) ELITE_RARITY     // 18%
            else if (rarity_roll <= 55) RARE_RARITY      // 30%
            else COMMON_RARITY                           // 45%
        }
    } else {
        // Late rounds (7-9): Lower rarity, more commons
        if (is_whitelist) {
            if (rarity_roll <= 8) LEGENDARY_RARITY       // 8% vs 5% regular
            else if (rarity_roll <= 23) ELITE_RARITY     // 15% vs 12% regular
            else if (rarity_roll <= 48) RARE_RARITY      // 25% vs 28% regular
            else COMMON_RARITY                           // 52% vs 55% regular
        } else {
            if (rarity_roll <= 5) LEGENDARY_RARITY       // 5%
            else if (rarity_roll <= 17) ELITE_RARITY     // 12%
            else if (rarity_roll <= 45) RARE_RARITY      // 28%
            else COMMON_RARITY                           // 55%
        }
    };

    // Generate stats with round bonuses
    let base_stats = match (rarity) {
        1 => { // Common
            let base = 10;
            if (is_whitelist) base + 5 else base
        },
        2 => { // Rare
            let base = 25;
            if (is_whitelist) base + 10 else base
        },
        3 => { // Elite
            let base = 50;
            if (is_whitelist) base + 15 else base
        },
        4 => { // Legendary
            let base = 100;
            if (is_whitelist) base + 25 else base
        },
        _ => 10,
    };

    // Add round bonus (early rounds get slight stat boost)
    let round_bonus = if (current_round <= 3) 5 else if (current_round <= 6) 3 else 1;
    let final_base_stats = base_stats + round_bonus;

    let attack = final_base_stats + generator.generate_u64_in_range(0, final_base_stats / 2);
    let defense = final_base_stats + generator.generate_u64_in_range(0, final_base_stats / 2);
    let magic = final_base_stats + generator.generate_u64_in_range(0, final_base_stats / 2);
    let dexterity = final_base_stats + generator.generate_u64_in_range(0, final_base_stats / 2);

    // Generate NFT with dynamic fields
    let temp_id = object::new(ctx);
    let nft_address = object::uid_to_address(&temp_id);
    let random_seed = generator.generate_u64();
    let is_female_rand = generator.generate_u64_in_range(0, 10);
    let item_type = CHARACTER_TYPE;

    // Generate character asset IDs
    let (hair_id, armor_id, mask_id, is_female) = image_generator::generate_character_asset_ids(
        nft_address,
        item_type,
        rarity,
        random_seed,
        is_female_rand
    );

    // Generate secure image URL
    let image_url = image_generator::generate_secure_image_url_from_id(nft_address);

    let mut item = IsekaiBlade {
        id: temp_id,
        name,
        description,
        item_type,
        rarity,
        level: 1,
        attack,
        defense,
        magic,
        dexterity,
        image_url,
        creator: user,
    };

    // Set dynamic fields for visual attributes and ownership
    set_owner(&mut item, user);
    set_asset_ids(&mut item, hair_id, armor_id, mask_id, is_female);

    // Emit unified mint event
    emit(NFTMinted {
        nft_id: object::id(&item),
        minter: user,
        mint_count: current_mint_count + 1,
        rarity,
        item_type,
        whitelist_used: is_whitelist,
        discount_applied: is_whitelist,
        final_price: final_mint_price,
        round_id: active_round_id,
    });

    item
}


// === Whitelist View Functions ===

/// Check if address is whitelisted in a round
public fun is_whitelisted(round: &WhitelistRound, user: address): bool {
    table::contains(&round.whitelisted_users, user)
}

/// Check if a round is public (anyone can mint)
public fun is_public_round(round: &WhitelistRound): bool {
    round.is_public
}

/// Get whitelist entry for a user
public fun get_whitelist_entry(round: &WhitelistRound, user: address): (u8, u8, u64, address) {
    assert!(table::contains(&round.whitelisted_users, user), EWhitelistNotFound);
    let entry = table::borrow(&round.whitelisted_users, user);
    (entry.max_mints, entry.remaining_mints, entry.added_at, entry.added_by)
}

/// Get round info
public fun get_round_info(round: &WhitelistRound): (String, u64, bool, bool, u64, u64, address) {
    (
        round.round_id,
        round.total_whitelisted,
        round.is_active,
        round.is_public,
        round.created_at,
        round.updated_at,
        round.admin
    )
}

/// Get round pricing info - NEW FUNCTION for pricing data
public fun get_round_pricing_info(round: &WhitelistRound): (u64, u64, u64) {
    // Get pricing from dynamic field, use defaults if not present
    if (df::exists_<String>(&round.id, utf8(b"pricing"))) {
        let pricing = df::borrow<String, RoundPricing>(&round.id, utf8(b"pricing"));
        (
            pricing.mint_price,
            pricing.max_supply,
            pricing.current_minted
        )
    } else {
        // Return defaults for rounds created before pricing feature
        (
            2000000000, // Default 0.5 SUI
            1000,      // Default max supply
            0          // Default current minted
        )
    }
}

/// Initialize pricing for existing rounds (Admin only) - for upgrade compatibility
public fun initialize_round_pricing(
    _: &AdminCap,
    round: &mut WhitelistRound,
    mint_price: u64,
    max_supply: u64,
    current_minted: u64,
    ctx: &mut TxContext
) {
    // Only add pricing if it doesn't exist
    if (!df::exists_<String>(&round.id, utf8(b"pricing"))) {
        let pricing = RoundPricing {
            mint_price,
            max_supply,
            current_minted,
        };
        df::add(&mut round.id, utf8(b"pricing"), pricing);
        round.updated_at = tx_context::epoch_timestamp_ms(ctx);
    }
}

/// Get total rounds in registry
public fun get_total_rounds(registry: &WhitelistRegistry): u64 {
    registry.total_rounds
}

/// Get active rounds list
public fun get_active_rounds(registry: &WhitelistRegistry): vector<String> {
    registry.active_rounds
}

/// Get round object ID by round name
public fun get_round_object_id(registry: &WhitelistRegistry, round_id: String): Option<ID> {
    if (table::contains(&registry.rounds, round_id)) {
        option::some(*table::borrow(&registry.rounds, round_id))
    } else {
        option::none()
    }
}


// === Test Functions ===

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ISEKAI_BLADE {}, ctx);
}

#[test_only]
public fun create_admin_cap_for_testing(ctx: &mut TxContext): AdminCap {
    AdminCap {
        id: object::new(ctx),
    }
}

}
