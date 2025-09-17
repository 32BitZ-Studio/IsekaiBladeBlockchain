// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: Attributes Chain - Generic attributes module for cross-game compatibility
module isekai_blade::attributes_chain;

use sui::event::emit;
use sui::table::Table;
use std::string::{String, utf8};
use std::option::{Option};
use sui::vec_map::{Self, VecMap};

// === Error Codes ===
const EAttributeNotFound: u64 = 0;
const EInvalidAttributeValue: u64 = 1;
const EAttributeAlreadyExists: u64 = 2;
const EInvalidCharacterAttributes: u64 = 3;
// const EMissingRequiredAttribute: u64 = 4; // Removed unused constant

// === Structs ===

/// Attribute value types
public struct AttributeValue has store, copy, drop {
    data_type: u8, // 0: string, 1: u64, 2: bool, 3: vector<u8>
    string_value: String,
    number_value: u64,
    bool_value: bool,
    bytes_value: vector<u8>,
}

/// Attribute metadata for schema definition
public struct AttributeMetadata has store, copy, drop {
    name: String,
    description: String,
    data_type: u8,
    is_mutable: bool,
    is_required: bool,
    min_value: u64,
    max_value: u64,
    allowed_values: vector<String>,
}

/// Attributes collection attached to NFTs
public struct AttributesChain has store, drop {
    attributes: VecMap<String, AttributeValue>,
    schema_version: u64,
    last_updated: u64,
}

/// Schema registry for attribute definitions
public struct AttributeSchema has key {
    id: UID,
    name: String,
    version: u64,
    metadata: VecMap<String, AttributeMetadata>,
    is_active: bool,
}

/// Registry for all schemas
public struct SchemaRegistry has key {
    id: UID,
    _schemas: Table<String, ID>,
    _latest_versions: Table<String, u64>,
}

// === Events ===

public struct AttributeUpdated has copy, drop {
    object_id: ID,
    attribute_name: String,
    old_value: AttributeValue,
    new_value: AttributeValue,
}

public struct AttributeAdded has copy, drop {
    object_id: ID,
    attribute_name: String,
    value: AttributeValue,
}

public struct AttributeRemoved has copy, drop {
    object_id: ID,
    attribute_name: String,
}

public struct SchemaCreated has copy, drop {
    schema_id: ID,
    name: String,
    version: u64,
}

// === Public Functions ===

/// Create a new attributes chain
public fun new_attributes_chain(ctx: &mut TxContext): AttributesChain {
    AttributesChain {
        attributes: vec_map::empty(),
        schema_version: 1,
        last_updated: tx_context::epoch(ctx),
    }
}

/// Create a new attribute schema
public fun create_schema(
    name: String,
    version: u64,
    ctx: &mut TxContext
): AttributeSchema {
    let schema = AttributeSchema {
        id: object::new(ctx),
        name,
        version,
        metadata: vec_map::empty(),
        is_active: true,
    };

    emit(SchemaCreated {
        schema_id: schema.id.to_inner(),
        name,
        version,
    });

    schema
}

/// Add attribute metadata to schema
public fun add_attribute_to_schema(
    schema: &mut AttributeSchema,
    metadata: AttributeMetadata,
) {
    vec_map::insert(&mut schema.metadata, metadata.name, metadata);
}

/// Create string attribute value
public fun create_string_attribute(value: String): AttributeValue {
    AttributeValue {
        data_type: 0,
        string_value: value,
        number_value: 0,
        bool_value: false,
        bytes_value: vector::empty(),
    }
}

/// Create number attribute value
public fun create_number_attribute(value: u64): AttributeValue {
    AttributeValue {
        data_type: 1,
        string_value: utf8(b""),
        number_value: value,
        bool_value: false,
        bytes_value: vector::empty(),
    }
}

/// Create boolean attribute value
public fun create_bool_attribute(value: bool): AttributeValue {
    AttributeValue {
        data_type: 2,
        string_value: utf8(b""),
        number_value: 0,
        bool_value: value,
        bytes_value: vector::empty(),
    }
}

/// Create bytes attribute value
public fun create_bytes_attribute(value: vector<u8>): AttributeValue {
    AttributeValue {
        data_type: 3,
        string_value: utf8(b""),
        number_value: 0,
        bool_value: false,
        bytes_value: value,
    }
}

/// Add attribute to chain
public fun add_attribute(
    chain: &mut AttributesChain,
    name: String,
    value: AttributeValue,
    object_id: ID,
    ctx: &mut TxContext
) {
    assert!(!vec_map::contains(&chain.attributes, &name), EAttributeAlreadyExists);
    
    vec_map::insert(&mut chain.attributes, name, value);
    chain.last_updated = tx_context::epoch(ctx);

    emit(AttributeAdded {
        object_id,
        attribute_name: name,
        value,
    });
}

/// Update existing attribute
public fun update_attribute(
    chain: &mut AttributesChain,
    name: String,
    new_value: AttributeValue,
    object_id: ID,
    ctx: &mut TxContext
) {
    assert!(vec_map::contains(&chain.attributes, &name), EAttributeNotFound);
    
    let old_value = *vec_map::get(&chain.attributes, &name);
    vec_map::remove(&mut chain.attributes, &name);
    vec_map::insert(&mut chain.attributes, name, new_value);
    
    chain.last_updated = tx_context::epoch(ctx);

    emit(AttributeUpdated {
        object_id,
        attribute_name: name,
        old_value,
        new_value,
    });
}

/// Remove attribute from chain
public fun remove_attribute(
    chain: &mut AttributesChain,
    name: String,
    object_id: ID,
    ctx: &mut TxContext
) {
    assert!(vec_map::contains(&chain.attributes, &name), EAttributeNotFound);
    
    vec_map::remove(&mut chain.attributes, &name);
    chain.last_updated = tx_context::epoch(ctx);

    emit(AttributeRemoved {
        object_id,
        attribute_name: name,
    });
}

/// Batch update multiple attributes
public fun batch_update_attributes(
    chain: &mut AttributesChain,
    updates: VecMap<String, AttributeValue>,
    object_id: ID,
    ctx: &mut TxContext
) {
    let keys = vec_map::keys(&updates);
    let mut i = 0;
    while (i < vector::length(&keys)) {
        let key = *vector::borrow(&keys, i);
        let value = *vec_map::get(&updates, &key);
        
        if (vec_map::contains(&chain.attributes, &key)) {
            update_attribute(chain, key, value, object_id, ctx);
        } else {
            add_attribute(chain, key, value, object_id, ctx);
        };
        
        i = i + 1;
    };
}

// === View Functions ===

/// Get attribute value
public fun get_attribute(chain: &AttributesChain, name: String): AttributeValue {
    assert!(vec_map::contains(&chain.attributes, &name), EAttributeNotFound);
    *vec_map::get(&chain.attributes, &name)
}

/// Check if attribute exists
public fun has_attribute(chain: &AttributesChain, name: String): bool {
    vec_map::contains(&chain.attributes, &name)
}

/// Get all attribute names
public fun get_attribute_names(chain: &AttributesChain): vector<String> {
    vec_map::keys(&chain.attributes)
}

/// Get attribute as string
public fun get_string_attribute(chain: &AttributesChain, name: String): String {
    let attr = get_attribute(chain, name);
    assert!(attr.data_type == 0, EInvalidAttributeValue);
    attr.string_value
}

/// Get attribute as number
public fun get_number_attribute(chain: &AttributesChain, name: String): u64 {
    let attr = get_attribute(chain, name);
    assert!(attr.data_type == 1, EInvalidAttributeValue);
    attr.number_value
}

/// Get attribute as boolean
public fun get_bool_attribute(chain: &AttributesChain, name: String): bool {
    let attr = get_attribute(chain, name);
    assert!(attr.data_type == 2, EInvalidAttributeValue);
    attr.bool_value
}

/// Get attribute as bytes
public fun get_bytes_attribute(chain: &AttributesChain, name: String): vector<u8> {
    let attr = get_attribute(chain, name);
    assert!(attr.data_type == 3, EInvalidAttributeValue);
    attr.bytes_value
}

/// Get schema version
public fun get_schema_version(chain: &AttributesChain): u64 {
    chain.schema_version
}

/// Get last updated epoch
public fun get_last_updated(chain: &AttributesChain): u64 {
    chain.last_updated
}

/// Get attribute count
public fun get_attribute_count(chain: &AttributesChain): u64 {
    vec_map::size(&chain.attributes)
}

// === Destructor Functions ===

/// Destroy an attributes chain
public fun destroy_attributes_chain(chain: AttributesChain) {
    let AttributesChain { 
        attributes: _,
        schema_version: _,
        last_updated: _
    } = chain;
}

// === Cross-Game Compatibility Functions ===

/// Serialize attributes for cross-game transfer
public fun serialize_attributes(_chain: &AttributesChain): vector<u8> {
    // This would contain serialization logic for cross-game compatibility
    // For now, return a placeholder
    b"serialized_attributes"
}

/// Deserialize attributes from external format
public fun deserialize_attributes(data: vector<u8>, ctx: &mut TxContext): AttributesChain {
    // This would contain deserialization logic
    // For now, return empty chain
    let _ = data; // Silence unused parameter warning
    new_attributes_chain(ctx)
}

/// Validate attribute against schema
public fun validate_attribute(
    schema: &AttributeSchema,
    name: String,
    value: &AttributeValue
): bool {
    if (!vec_map::contains(&schema.metadata, &name)) {
        return false
    };
    
    let metadata = vec_map::get(&schema.metadata, &name);
    
    // Check data type match
    if (metadata.data_type != value.data_type) {
        return false
    };
    
    // Additional validation based on metadata constraints
    if (metadata.data_type == 1) { // number type
        if (value.number_value < metadata.min_value || value.number_value > metadata.max_value) {
            return false
        };
    };
    
    true
}

// === Helper Functions ===

/// Create attribute metadata
public fun create_attribute_metadata(
    name: String,
    description: String,
    data_type: u8,
    is_mutable: bool,
    is_required: bool,
    min_value: u64,
    max_value: u64,
    allowed_values: vector<String>
): AttributeMetadata {
    AttributeMetadata {
        name,
        description,
        data_type,
        is_mutable,
        is_required,
        min_value,
        max_value,
        allowed_values,
    }
}

// === Character Validation Functions ===

/// Character item type constant
const CHARACTER_ITEM_TYPE: u8 = 0;

/// Create character attributes with validation
public fun create_character_attributes(
    strength: u64,
    dexterity: u64,
    constitution: u64,
    chakra: u64,
    addition: String,
    object_id: ID,
    ctx: &mut TxContext
): AttributesChain {
    let mut chain = new_attributes_chain(ctx);
    
    // Add the 5 required character attributes
    add_attribute(
        &mut chain,
        utf8(b"strength"),
        create_number_attribute(strength),
        object_id,
        ctx
    );
    
    add_attribute(
        &mut chain,
        utf8(b"dexterity"),
        create_number_attribute(dexterity),
        object_id,
        ctx
    );
    
    add_attribute(
        &mut chain,
        utf8(b"constitution"),
        create_number_attribute(constitution),
        object_id,
        ctx
    );
    
    add_attribute(
        &mut chain,
        utf8(b"chakra"),
        create_number_attribute(chakra),
        object_id,
        ctx
    );
    
    add_attribute(
        &mut chain,
        utf8(b"addition"),
        create_string_attribute(addition),
        object_id,
        ctx
    );
    
    chain
}

/// Validate that character has all required attributes
public fun validate_character_attributes(chain: &AttributesChain): bool {
    // Check that all 5 required attributes exist
    let required_attrs = vector[
        utf8(b"strength"),
        utf8(b"dexterity"),
        utf8(b"constitution"),
        utf8(b"chakra"),
        utf8(b"addition")
    ];
    
    let mut i = 0;
    while (i < vector::length(&required_attrs)) {
        let attr_name = *vector::borrow(&required_attrs, i);
        if (!has_attribute(chain, attr_name)) {
            return false
        };
        i = i + 1;
    };
    
    // Validate that numeric attributes are within reasonable bounds (0-999)
    if (has_attribute(chain, utf8(b"strength"))) {
        let strength = get_number_attribute(chain, utf8(b"strength"));
        if (strength > 999) return false;
    };
    
    if (has_attribute(chain, utf8(b"dexterity"))) {
        let dexterity = get_number_attribute(chain, utf8(b"dexterity"));
        if (dexterity > 999) return false;
    };
    
    if (has_attribute(chain, utf8(b"constitution"))) {
        let constitution = get_number_attribute(chain, utf8(b"constitution"));
        if (constitution > 999) return false;
    };
    
    if (has_attribute(chain, utf8(b"chakra"))) {
        let chakra = get_number_attribute(chain, utf8(b"chakra"));
        if (chakra > 999) return false;
    };
    
    true
}

/// Assert character attributes are valid (used in minting)
public fun assert_valid_character_attributes(chain: &AttributesChain) {
    assert!(validate_character_attributes(chain), EInvalidCharacterAttributes);
}

/// Update character attributes with validation
public fun update_character_attributes(
    chain: &mut AttributesChain,
    mut strength: Option<u64>,
    mut dexterity: Option<u64>,
    mut constitution: Option<u64>,
    mut chakra: Option<u64>,
    mut addition: Option<String>,
    object_id: ID,
    ctx: &mut TxContext
) {
    // Update strength if provided
    if (option::is_some(&strength)) {
        let value = option::extract(&mut strength);
        assert!(value <= 999, EInvalidAttributeValue);
        update_attribute(
            chain,
            utf8(b"strength"),
            create_number_attribute(value),
            object_id,
            ctx
        );
    };
    
    // Update dexterity if provided
    if (option::is_some(&dexterity)) {
        let value = option::extract(&mut dexterity);
        assert!(value <= 999, EInvalidAttributeValue);
        update_attribute(
            chain,
            utf8(b"dexterity"),
            create_number_attribute(value),
            object_id,
            ctx
        );
    };
    
    // Update constitution if provided
    if (option::is_some(&constitution)) {
        let value = option::extract(&mut constitution);
        assert!(value <= 999, EInvalidAttributeValue);
        update_attribute(
            chain,
            utf8(b"constitution"),
            create_number_attribute(value),
            object_id,
            ctx
        );
    };
    
    // Update chakra if provided
    if (option::is_some(&chakra)) {
        let value = option::extract(&mut chakra);
        assert!(value <= 999, EInvalidAttributeValue);
        update_attribute(
            chain,
            utf8(b"chakra"),
            create_number_attribute(value),
            object_id,
            ctx
        );
    };
    
    // Update addition if provided
    if (option::is_some(&addition)) {
        let value = option::extract(&mut addition);
        update_attribute(
            chain,
            utf8(b"addition"),
            create_string_attribute(value),
            object_id,
            ctx
        );
    };
}

/// Get character attribute values
public fun get_character_attributes(chain: &AttributesChain): (u64, u64, u64, u64, String) {
    assert_valid_character_attributes(chain);
    (
        get_number_attribute(chain, utf8(b"strength")),
        get_number_attribute(chain, utf8(b"dexterity")),
        get_number_attribute(chain, utf8(b"constitution")),
        get_number_attribute(chain, utf8(b"chakra")),
        get_string_attribute(chain, utf8(b"addition"))
    )
}

// === Test Functions ===

#[test_only]
public fun create_test_attributes_chain(ctx: &mut TxContext): AttributesChain {
    let mut chain = new_attributes_chain(ctx);
    
    // Add some test attributes
    add_attribute(
        &mut chain,
        utf8(b"power"),
        create_number_attribute(100),
        object::id_from_address(@0x1),
        ctx
    );
    
    add_attribute(
        &mut chain,
        utf8(b"element"),
        create_string_attribute(utf8(b"fire")),
        object::id_from_address(@0x1),
        ctx
    );
    
    chain
}