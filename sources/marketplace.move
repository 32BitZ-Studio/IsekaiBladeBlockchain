// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: Enhanced Marketplace - Listing, buying, cancelling, auctions, composite sets
module isekai_blade::marketplace;

use sui::event::emit;
use sui::coin::{Self, Coin};
use sui::balance::{Self as balance, Balance};
use sui::sui::SUI;
use sui::table::{Self as table, Table};
use sui::clock::{Self as clock, Clock};
use std::string::{String, utf8};
use isekai_blade::access_control::AdminCap;
use isekai_blade::isekai_blade::{Self, IsekaiBlade, Listing};
use isekai_blade::collection::{Self as collection, Collection};

// === Error Codes ===
const ENotAuthorized: u64 = 0;
const EListingNotFound: u64 = 1;
const EListingExpired: u64 = 2;
const EInsufficientPayment: u64 = 3;
const EAuctionActive: u64 = 4;
const EAuctionEnded: u64 = 5;
const EBidTooLow: u64 = 6;
// const EInvalidListingType: u64 = 7; // Removed unused constant
const ECompositeSetIncomplete: u64 = 8;
const EMarketplacePaused: u64 = 9;

// === Constants ===
const MARKETPLACE_FEE_BPS: u64 = 250; // 2.5%
const BASIS_POINTS: u64 = 10000;
// const MIN_BID_INCREMENT_BPS: u64 = 500; // 5% // Removed unused constant
const AUCTION_EXTENSION_TIME: u64 = 600000; // 10 minutes in ms

// === Enums ===
const LISTING_TYPE_FIXED: u8 = 0;
// const LISTING_TYPE_AUCTION: u8 = 1; // Removed unused constant
// const LISTING_TYPE_BUNDLE: u8 = 2; // Removed unused constant

// === Structs ===

/// Main marketplace object
public struct Marketplace has key {
    id: UID,
    listings: Table<ID, Listing>,
    auctions: Table<ID, Auction>,
    bundles: Table<ID, Bundle>,
    escrow: Table<ID, IsekaiBlade>, // Store NFTs in escrow during listing
    marketplace_fee: u64, // basis points
    is_paused: bool,
    total_volume: u64,
    total_fees: Balance<SUI>,
}

// Listing struct imported from isekai_blade module

/// Auction listing with bidding mechanics
public struct Auction has store {
    id: ID,
    item_id: ID,
    seller: address,
    reserve_price: u64,
    current_bid: u64,
    highest_bidder: address,
    bid_increment: u64,
    start_time: u64,
    end_time: u64,
    auto_extend: bool,
    is_active: bool,
    bid_history: vector<Bid>,
}

/// Bid record
public struct Bid has store, copy, drop {
    bidder: address,
    amount: u64,
    timestamp: u64,
}

/// Bundle for selling composite sets
public struct Bundle has store {
    id: ID,
    item_ids: vector<ID>,
    seller: address,
    total_price: u64,
    individual_prices: vector<u64>,
    is_complete_set: bool,
    expiry: u64,
    is_active: bool,
}

/// Marketplace configuration
public struct MarketplaceConfig has key {
    id: UID,
    admin: address,
    fee_recipient: address,
    marketplace_fee: u64,
    min_listing_duration: u64,
    max_listing_duration: u64,
    min_auction_duration: u64,
    max_auction_duration: u64,
}

// === Events ===

public struct ListingCreated has copy, drop {
    listing_id: ID,
    item_id: ID,
    seller: address,
    price: u64,
    listing_type: u8,
    expiry: u64,
}

public struct ListingCancelled has copy, drop {
    listing_id: ID,
    item_id: ID,
    seller: address,
    reason: String,
}

public struct ItemSold has copy, drop {
    listing_id: ID,
    item_id: ID,
    seller: address,
    buyer: address,
    price: u64,
    marketplace_fee: u64,
    royalty_fee: u64,
}

public struct AuctionCreated has copy, drop {
    auction_id: ID,
    item_id: ID,
    seller: address,
    reserve_price: u64,
    start_time: u64,
    end_time: u64,
}

public struct BidPlaced has copy, drop {
    auction_id: ID,
    bidder: address,
    bid_amount: u64,
    previous_bid: u64,
    timestamp: u64,
}

public struct AuctionEnded has copy, drop {
    auction_id: ID,
    item_id: ID,
    winner: address,
    winning_bid: u64,
    total_bids: u64,
}

public struct BundleCreated has copy, drop {
    bundle_id: ID,
    seller: address,
    item_count: u64,
    total_price: u64,
}

public struct BundleSold has copy, drop {
    bundle_id: ID,
    seller: address,
    buyer: address,
    item_count: u64,
    total_price: u64,
}

// === Public Functions ===

/// Initialize marketplace
public fun create_marketplace(
    _admin_cap: &AdminCap,
    marketplace_fee: u64,
    _fee_recipient: address,
    ctx: &mut TxContext
): Marketplace {
    Marketplace {
        id: object::new(ctx),
        listings: table::new(ctx),
        auctions: table::new(ctx),
        bundles: table::new(ctx),
        escrow: table::new(ctx),
        marketplace_fee,
        is_paused: false,
        total_volume: 0,
        total_fees: balance::zero(),
    }
}

/// Create fixed price listing
public fun create_listing(
    marketplace: &mut Marketplace,
    item: IsekaiBlade,
    price: u64,
    expiry: u64,
    clock: &Clock,
    ctx: &mut TxContext
): ID {
    assert!(!marketplace.is_paused, EMarketplacePaused);
    
    let current_time = clock::timestamp_ms(clock);
    assert!(expiry > current_time, EListingExpired);
    
    let item_id = object::id(&item);
    let listing_id = object::new(ctx);
    let listing_id_inner = listing_id.to_inner();
    
    // Create listing with NFT attributes
    let listing = isekai_blade::create_listing_from_item(&item, item_id, ctx.sender(), price);
    
    // Store the item in escrow during listing
    table::add(&mut marketplace.escrow, item_id, item);
    
    table::add(&mut marketplace.listings, listing_id_inner, listing);
    
    emit(ListingCreated {
        listing_id: listing_id_inner,
        item_id,
        seller: ctx.sender(),
        price,
        listing_type: LISTING_TYPE_FIXED,
        expiry,
    });
    
    object::delete(listing_id);
    listing_id_inner
}

/// Create auction listing
public fun create_auction(
    marketplace: &mut Marketplace,
    item: IsekaiBlade,
    reserve_price: u64,
    duration: u64,
    bid_increment: u64,
    clock: &Clock,
    ctx: &mut TxContext
): ID {
    assert!(!marketplace.is_paused, EMarketplacePaused);
    
    let current_time = clock::timestamp_ms(clock);
    let end_time = current_time + duration;
    let item_id = object::id(&item);
    let auction_id = object::new(ctx);
    let auction_id_inner = auction_id.to_inner();
    
    let auction = Auction {
        id: auction_id_inner,
        item_id,
        seller: ctx.sender(),
        reserve_price,
        current_bid: 0,
        highest_bidder: @0x0,
        bid_increment,
        start_time: current_time,
        end_time,
        auto_extend: true,
        is_active: true,
        bid_history: vector::empty(),
    };
    
    transfer::public_transfer(item, @isekai_blade);
    
    table::add(&mut marketplace.auctions, auction_id_inner, auction);
    
    emit(AuctionCreated {
        auction_id: auction_id_inner,
        item_id,
        seller: ctx.sender(),
        reserve_price,
        start_time: current_time,
        end_time,
    });
    
    object::delete(auction_id);
    auction_id_inner
}

/// Place bid on auction
public fun place_bid(
    marketplace: &mut Marketplace,
    auction_id: ID,
    bid_payment: Coin<SUI>,
    clock: &Clock,
    ctx: &mut TxContext
) {
    assert!(!marketplace.is_paused, EMarketplacePaused);
    assert!(table::contains(&marketplace.auctions, auction_id), EListingNotFound);
    
    let auction = table::borrow_mut(&mut marketplace.auctions, auction_id);
    let current_time = clock::timestamp_ms(clock);
    
    assert!(auction.is_active, EAuctionEnded);
    assert!(current_time < auction.end_time, EAuctionEnded);
    
    let bid_amount = coin::value(&bid_payment);
    let min_bid = if (auction.current_bid == 0) {
        auction.reserve_price
    } else {
        auction.current_bid + auction.bid_increment
    };
    
    assert!(bid_amount >= min_bid, EBidTooLow);
    
    // Return previous bid if exists
    if (auction.current_bid > 0 && auction.highest_bidder != @0x0) {
        // In a real implementation, you'd need to handle returning the previous bid
        // This requires a more complex escrow system
    };
    
    let previous_bid = auction.current_bid;
    auction.current_bid = bid_amount;
    auction.highest_bidder = ctx.sender();
    
    // Add to bid history
    let bid_record = Bid {
        bidder: ctx.sender(),
        amount: bid_amount,
        timestamp: current_time,
    };
    vector::push_back(&mut auction.bid_history, bid_record);
    
    // Auto-extend if bid placed near end
    if (auction.auto_extend && (auction.end_time - current_time) < AUCTION_EXTENSION_TIME) {
        auction.end_time = auction.end_time + AUCTION_EXTENSION_TIME;
    };
    
    // Store the bid (simplified - real implementation needs proper escrow)
    transfer::public_transfer(bid_payment, @isekai_blade);
    
    emit(BidPlaced {
        auction_id,
        bidder: ctx.sender(),
        bid_amount,
        previous_bid,
        timestamp: current_time,
    });
}

// DISABLED: Complex buy_item function with dependencies on Collection and Clock
// Use buy_item_safe instead for basic functionality

/// Create bundle listing for composite sets
public fun create_bundle(
    marketplace: &mut Marketplace,
    mut items: vector<IsekaiBlade>,
    individual_prices: vector<u64>,
    bundle_discount: u64, // basis points discount
    expiry: u64,
    clock: &Clock,
    ctx: &mut TxContext
): ID {
    assert!(!marketplace.is_paused, EMarketplacePaused);
    assert!(vector::length(&items) == vector::length(&individual_prices), ECompositeSetIncomplete);
    
    let current_time = clock::timestamp_ms(clock);
    assert!(expiry > current_time, EListingExpired);
    
    let mut item_ids = vector::empty<ID>();
    let mut total_individual_price = 0;
    let mut i = 0;
    
    // Process items
    while (i < vector::length(&items)) {
        let item = vector::pop_back(&mut items);
        let item_id = object::id(&item);
        vector::push_back(&mut item_ids, item_id);
        
        let individual_price = *vector::borrow(&individual_prices, i);
        total_individual_price = total_individual_price + individual_price;
        
        transfer::public_transfer(item, @isekai_blade);
        i = i + 1;
    };
    vector::destroy_empty(items);
    
    // Apply bundle discount
    let discount_amount = (total_individual_price * bundle_discount) / BASIS_POINTS;
    let total_price = total_individual_price - discount_amount;
    
    let bundle_id = object::new(ctx);
    let bundle_id_inner = bundle_id.to_inner();
    
    let bundle = Bundle {
        id: bundle_id_inner,
        item_ids,
        seller: ctx.sender(),
        total_price,
        individual_prices,
        is_complete_set: true,
        expiry,
        is_active: true,
    };
    
    let item_count = vector::length(&bundle.item_ids);
    table::add(&mut marketplace.bundles, bundle_id_inner, bundle);
    
    emit(BundleCreated {
        bundle_id: bundle_id_inner,
        seller: ctx.sender(),
        item_count,
        total_price,
    });
    
    object::delete(bundle_id);
    bundle_id_inner
}

// DISABLED: cancel_listing function incompatible with new Listing struct
// Use delist_item_safe instead

/// End auction
public fun end_auction(
    marketplace: &mut Marketplace,
    auction_id: ID,
    collection: &mut Collection,
    clock: &Clock,
    ctx: &mut TxContext
) {
    assert!(table::contains(&marketplace.auctions, auction_id), EListingNotFound);
    
    let auction = table::borrow_mut(&mut marketplace.auctions, auction_id);
    let current_time = clock::timestamp_ms(clock);
    
    assert!(current_time >= auction.end_time, EAuctionActive);
    assert!(auction.is_active, EAuctionEnded);
    
    auction.is_active = false;
    
    if (auction.current_bid >= auction.reserve_price && auction.highest_bidder != @0x0) {
        // Process payment similar to buy_item
        let sale_price = auction.current_bid;
        let marketplace_fee = (sale_price * marketplace.marketplace_fee) / BASIS_POINTS;
        let royalty_amount = collection::calculate_royalty(collection, sale_price);
        
        // Update volume
        marketplace.total_volume = marketplace.total_volume + sale_price;
    };
    
    emit(AuctionEnded {
        auction_id,
        item_id: auction.item_id,
        winner: auction.highest_bidder,
        winning_bid: auction.current_bid,
        total_bids: vector::length(&auction.bid_history),
    });
}

// === Admin Functions ===

public fun set_marketplace_fee(
    _admin_cap: &AdminCap,
    marketplace: &mut Marketplace,
    new_fee: u64
) {
    marketplace.marketplace_fee = new_fee;
}

public fun pause_marketplace(
    _admin_cap: &AdminCap,
    marketplace: &mut Marketplace,
    paused: bool
) {
    marketplace.is_paused = paused;
}

public fun withdraw_fees(
    _admin_cap: &AdminCap,
    marketplace: &mut Marketplace,
    amount: u64,
    ctx: &mut TxContext
): Coin<SUI> {
    let withdrawn = balance::split(&mut marketplace.total_fees, amount);
    coin::from_balance(withdrawn, ctx)
}

// === View Functions ===

public fun get_listing(marketplace: &Marketplace, listing_id: ID): &Listing {
    table::borrow(&marketplace.listings, listing_id)
}

public fun get_auction(marketplace: &Marketplace, auction_id: ID): &Auction {
    table::borrow(&marketplace.auctions, auction_id)
}

public fun get_bundle(marketplace: &Marketplace, bundle_id: ID): &Bundle {
    table::borrow(&marketplace.bundles, bundle_id)
}

public fun total_volume(marketplace: &Marketplace): u64 {
    marketplace.total_volume
}

public fun total_fees(marketplace: &Marketplace): u64 {
    balance::value(&marketplace.total_fees)
}

public fun is_paused(marketplace: &Marketplace): bool {
    marketplace.is_paused
}

// === Test Functions ===

#[test_only]
public fun create_test_marketplace(ctx: &mut TxContext): Marketplace {
    Marketplace {
        id: object::new(ctx),
        listings: table::new(ctx),
        auctions: table::new(ctx),
        bundles: table::new(ctx),
        escrow: table::new(ctx),
        marketplace_fee: MARKETPLACE_FEE_BPS,
        is_paused: false,
        total_volume: 0,
        total_fees: balance::zero(),
    }
}

// === New Escrow-Enabled Functions ===

/// Initialize marketplace with escrow functionality
public fun init_marketplace(admin_cap: &AdminCap, ctx: &mut TxContext) {
    let marketplace = create_marketplace(admin_cap, MARKETPLACE_FEE_BPS, ctx.sender(), ctx);
    transfer::share_object(marketplace);
}

/// List an item for sale - Simple version with escrow
public fun list_item_safe(
    marketplace: &mut Marketplace,
    escrow: &mut Table<ID, IsekaiBlade>,
    item: IsekaiBlade,
    price: u64,
    ctx: &mut TxContext
): ID {
    assert!(!marketplace.is_paused, EMarketplacePaused);
    
    let item_id = object::id(&item);
    let listing_id = object::new(ctx);
    let listing_id_inner = listing_id.to_inner();
    
    // Create listing with NFT attributes
    let listing = isekai_blade::create_listing_from_item(&item, item_id, ctx.sender(), price);
    
    // Store the item in escrow during listing
    table::add(&mut marketplace.escrow, item_id, item);
    
    table::add(&mut marketplace.listings, listing_id_inner, listing);
    
    emit(ListingCreated {
        listing_id: listing_id_inner,
        item_id,
        seller: ctx.sender(),
        price,
        listing_type: LISTING_TYPE_FIXED,
        expiry: 0,
    });
    
    object::delete(listing_id);
    listing_id_inner
}

/// Buy an item from marketplace - Simple version with escrow
public fun buy_item_safe(
    marketplace: &mut Marketplace,
    escrow: &mut Table<ID, IsekaiBlade>,
    item_id: ID,
    mut payment: Coin<SUI>,
    ctx: &mut TxContext
) {
    assert!(!marketplace.is_paused, EMarketplacePaused);
    assert!(table::contains(&marketplace.listings, item_id), EListingNotFound);
    assert!(table::contains(&marketplace.escrow, item_id), EListingNotFound);
    
    let listing = table::borrow(&marketplace.listings, item_id);
    assert!(coin::value(&payment) >= isekai_blade::listing_price(listing), EInsufficientPayment);
    
    let seller = isekai_blade::listing_seller(listing);
    let price = isekai_blade::listing_price(listing);
    
    // Remove the listing
    let _removed_listing = table::remove(&mut marketplace.listings, item_id);
    
    // Calculate fees
    let marketplace_fee = (price * marketplace.marketplace_fee) / BASIS_POINTS;
    let royalty_amount = 0; // Simplified - no royalty calculation
    let _seller_amount = price - marketplace_fee - royalty_amount;
    
    // Split payment
    let fee_coin = coin::split(&mut payment, marketplace_fee, ctx);
    balance::join(&mut marketplace.total_fees, coin::into_balance(fee_coin));
    
    // Transfer payment to seller
    transfer::public_transfer(payment, seller);
    
    // Transfer NFT from escrow to buyer
    let nft = table::remove(&mut marketplace.escrow, item_id);
    transfer::public_transfer(nft, ctx.sender());
    
    // Update total volume
    marketplace.total_volume = marketplace.total_volume + price;
    
    emit(ItemSold {
        listing_id: item_id,
        item_id,
        seller,
        buyer: ctx.sender(),
        price,
        marketplace_fee,
        royalty_fee: royalty_amount,
    });
}

/// Delist an item from marketplace - Simple version with escrow
public fun delist_item_safe(
    marketplace: &mut Marketplace,
    _escrow: &mut Table<ID, IsekaiBlade>,
    item_id: ID,
    ctx: &mut TxContext
) {
    assert!(!marketplace.is_paused, EMarketplacePaused);
    assert!(table::contains(&marketplace.listings, item_id), EListingNotFound);
    assert!(table::contains(&marketplace.escrow, item_id), EListingNotFound);
    
    let listing = table::borrow(&marketplace.listings, item_id);
    assert!(isekai_blade::listing_seller(listing) == ctx.sender(), ENotAuthorized);
    
    // Remove the listing
    let _removed_listing = table::remove(&mut marketplace.listings, item_id);
    
    // Return NFT from escrow to seller
    let nft = table::remove(&mut marketplace.escrow, item_id);
    transfer::public_transfer(nft, ctx.sender());
    
    emit(ListingCancelled {
        listing_id: item_id,
        item_id,
        seller: ctx.sender(),
        reason: utf8(b"Cancelled by seller"),
    });
}