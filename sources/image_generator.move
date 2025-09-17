// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: Image Generator - Secure image URL generation based on item attributes
module isekai_blade::image_generator;

use std::string::{String, utf8};
use std::bcs;

// Item type constants
const CHARACTER_TYPE: u8 = 5;


// === Public Functions ===

/// Generate secure image URL using NFT object ID
/// Format: /api/nft-image/{nft_id}
/// NFT data is fetched directly from blockchain for maximum security
public fun generate_secure_image_url_from_id(nft_id: address): String {
    let mut url = utf8(b"https://marketplace.isekaiblade.com/api/nft-image/0x");

    // Convert address to hex string and append
    let hex_bytes = address_to_hex_bytes(nft_id);
    url.append(utf8(hex_bytes));

    url
}
//
// /// Legacy function: Generate secure image URL using blockchain-generated asset parameters
// /// Format: /api/generate-image?r={rarity}&t={type}&l={level}&h={hair_id}&ar={armor_id}&m={mask_id}&f={is_female}
// /// @deprecated Use generate_secure_image_url_from_id instead
// public fun generate_secure_image_url_with_assets(
//     rarity: u8,
//     item_type: u8,
//     level: u8,
//     hair_id: u8,
//     armor_id: u8,
//     mask_id: u8,
//     is_female: bool
// ): String {
//     let mut url = utf8(b"/api/generate-image?r=");
//
//     // Add rarity
//     url.append(utf8(u8_to_string(rarity)));
//     url.append(utf8(b"&t="));
//
//     // Add item type
//     url.append(utf8(u8_to_string(item_type)));
//     url.append(utf8(b"&l="));
//
//     // Add level
//     url.append(utf8(u8_to_string(level)));
//     url.append(utf8(b"&h="));
//
//     // Add hair ID
//     url.append(utf8(u8_to_string(hair_id)));
//     url.append(utf8(b"&ar="));
//
//     // Add armor ID
//     url.append(utf8(u8_to_string(armor_id)));
//     url.append(utf8(b"&m="));
//
//     // Add mask ID
//     url.append(utf8(u8_to_string(mask_id)));
//     url.append(utf8(b"&f="));
//
//     // Add gender (1 for female, 0 for male)
//     let gender_str = if (is_female) { b"1" } else { b"0" };
//     url.append(utf8(gender_str));
//
//     url
// }


/// Generate random asset IDs based on character gender only
/// Uses actual asset folder structure for proper ID generation
/// Asset Structure:
/// - Hair Female: 71-140.png (70 assets)
/// - Hair Male: 1-70.png (70 assets)
/// - Armor Female: 11-20.png (10 assets)
/// - Armor Male: 1-10.png (10 assets)
/// - Mask: 1-8.png (8 unisex masks, 20% chance, elite+ only)
public fun generate_character_asset_ids(
    _nft_address: address,
    item_type: u8,
    rarity: u8,
    random_seed: u64,
    is_female_rand: u64
): (u8, u8, u8, bool) {
    // Only generate character assets for character type (type 5)
    if (item_type != CHARACTER_TYPE) {
        return (1, 1, 0, false) // Default values for non-character items
    };

    // Generate deterministic gender based on NFT address
    let is_female = is_female_rand % 2 == 0;

    // Generate hair ID based on gender only - pure random
    let hair_id = if (is_female) {
        // Female hair: 71-140 (70 options)
        let hair_variation = (random_seed % 70) as u8;
        71 + hair_variation
    } else {
        // Male hair: 1-70 (70 options)
        let hair_variation = (random_seed % 70) as u8;
        if (hair_variation == 0) { 70 } else { hair_variation }
    };

    // Generate armor ID based on gender only - pure random
    let armor_id = if (is_female) {
        // Female armor: 11-20 (10 options)
        let armor_variation = ((random_seed / 100) % 10) as u8;
        11 + armor_variation
    } else {
        // Male armor: 1-10 (10 options)
        let armor_variation = ((random_seed / 100) % 10) as u8;
        if (armor_variation == 0) { 10 } else { armor_variation }
    };

    // Generate mask ID - 20% chance, only for elite+ rarity (3, 4, 5)
    let mask_id = if (rarity >= 3) { // Elite, Legendary, Mythic
        let mask_chance = (random_seed / 1000) % 10;
        if (mask_chance < 2) { // 20% chance to have a mask
            let mask_variation = ((random_seed / 10000) % 8) as u8;
            if (mask_variation == 0) { 8 } else { mask_variation }
        } else {
            0 // No mask
        }
    } else {
        0 // No mask for common and rare
    };

    (hair_id, armor_id, mask_id, is_female)
}

/// Convert address to hex bytes for URL construction
fun address_to_hex_bytes(addr: address): vector<u8> {
    let addr_bytes = bcs::to_bytes(&addr);
    let mut hex_result = vector::empty<u8>();
    let hex_chars = b"0123456789abcdef";

    let mut i = 0;
    while (i < vector::length(&addr_bytes)) {
        let byte = *vector::borrow(&addr_bytes, i);
        let high_nibble = (byte >> 4) & 0xF;
        let low_nibble = byte & 0xF;

        vector::push_back(&mut hex_result, *vector::borrow(&hex_chars, (high_nibble as u64)));
        vector::push_back(&mut hex_result, *vector::borrow(&hex_chars, (low_nibble as u64)));
        i = i + 1;
    };

    hex_result
}

// /// Convert u8 to string representation (extended range)
// fun u8_to_string(value: u8): vector<u8> {
//     // Supports 0–255 safely
//     if (value == 0) {
//         return b"0"
//     };
//
//     let mut out = vector::empty<u8>();
//     let mut v = value;
//     let mut digits = vector::empty<u8>();
//
//     while (v > 0) {
//         let digit = (v % 10) as u8;
//         vector::push_back(&mut digits, 48 + digit); // ASCII '0' + digit
//         v = v / 10;
//     };
//
//     // Reverse digits into out
//     while (!vector::is_empty(&digits)) {
//         let d = *vector::borrow(&digits, vector::length(&digits) - 1);
//         vector::push_back(&mut out, d);
//         vector::pop_back(&mut digits);
//     };
//
//     out
// }

