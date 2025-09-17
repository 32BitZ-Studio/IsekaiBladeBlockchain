// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Module: Access Control - Admin capabilities & role management
module isekai_blade::access_control;

use sui::event::emit;
use sui::table::{Self, Table};
use std::string::{Self, String};

// === Error Codes ===
const ENotAuthorized: u64 = 0;
// const ERoleAlreadyExists: u64 = 1; // Removed unused constant
const ERoleDoesNotExist: u64 = 2;
// const EInvalidRole: u64 = 3; // Removed unused constant

// === Constants ===
const ADMIN_ROLE: vector<u8> = b"ADMIN";
const MINTER_ROLE: vector<u8> = b"MINTER";
const MARKETPLACE_ADMIN_ROLE: vector<u8> = b"MARKETPLACE_ADMIN";
const UPGRADER_ROLE: vector<u8> = b"UPGRADER";

// === Structs ===

/// Owner capability - the highest level of access
public struct OwnerCap has key, store {
    id: UID,
}

/// Role-based access capability
public struct RoleCap has key, store {
    id: UID,
    role: String,
    granted_by: address,
}

/// Registry for tracking roles and permissions
public struct RoleRegistry has key {
    id: UID,
    owner: address,
    roles: Table<String, vector<address>>,
}

/// Admin capability for specific operations
public struct AdminCap has key, store {
    id: UID,
    permissions: vector<String>,
}

// === Events ===

public struct RoleGranted has copy, drop {
    role: String,
    grantee: address,
    granted_by: address,
}

public struct RoleRevoked has copy, drop {
    role: String,
    revokee: address,
    revoked_by: address,
}

public struct AdminCapCreated has copy, drop {
    admin_cap_id: ID,
    owner: address,
    permissions: vector<String>,
}

// === Public Functions ===

/// Initialize the access control system (called in init)
public fun init_access_control(ctx: &mut TxContext): (OwnerCap, RoleRegistry) {
    let owner_cap = OwnerCap {
        id: object::new(ctx),
    };

    let role_registry = RoleRegistry {
        id: object::new(ctx),
        owner: ctx.sender(),
        roles: table::new(ctx),
    };

    (owner_cap, role_registry)
}

/// Create a new admin capability with specific permissions
public fun create_admin_cap(
    _owner_cap: &OwnerCap,
    permissions: vector<String>,
    ctx: &mut TxContext
): AdminCap {
    let admin_cap = AdminCap {
        id: object::new(ctx),
        permissions,
    };

    emit(AdminCapCreated {
        admin_cap_id: admin_cap.id.to_inner(),
        owner: ctx.sender(),
        permissions,
    });

    admin_cap
}

/// Grant a role to an address
public fun grant_role(
    _owner_cap: &OwnerCap,
    registry: &mut RoleRegistry,
    role: String,
    grantee: address,
    ctx: &mut TxContext
) {
    if (!table::contains(&registry.roles, role)) {
        table::add(&mut registry.roles, role, vector::empty());
    };

    let role_holders = table::borrow_mut(&mut registry.roles, role);
    if (!vector::contains(role_holders, &grantee)) {
        vector::push_back(role_holders, grantee);
    };

    emit(RoleGranted {
        role,
        grantee,
        granted_by: ctx.sender(),
    });
}

/// Revoke a role from an address
public fun revoke_role(
    _owner_cap: &OwnerCap,
    registry: &mut RoleRegistry,
    role: String,
    revokee: address,
    ctx: &mut TxContext
) {
    assert!(table::contains(&registry.roles, role), ERoleDoesNotExist);

    let role_holders = table::borrow_mut(&mut registry.roles, role);
    let (exists, index) = vector::index_of(role_holders, &revokee);
    
    if (exists) {
        vector::remove(role_holders, index);
    };

    emit(RoleRevoked {
        role,
        revokee,
        revoked_by: ctx.sender(),
    });
}

/// Create a role capability for an address
public fun create_role_cap(
    _owner_cap: &OwnerCap,
    registry: &RoleRegistry,
    role: String,
    recipient: address,
    ctx: &mut TxContext
): RoleCap {
    assert!(has_role(registry, role, recipient), ENotAuthorized);

    RoleCap {
        id: object::new(ctx),
        role,
        granted_by: ctx.sender(),
    }
}

// === View Functions ===

/// Check if an address has a specific role
public fun has_role(registry: &RoleRegistry, role: String, addr: address): bool {
    if (!table::contains(&registry.roles, role)) {
        return false
    };

    let role_holders = table::borrow(&registry.roles, role);
    vector::contains(role_holders, &addr)
}

/// Check if admin cap has a specific permission
public fun has_permission(admin_cap: &AdminCap, permission: String): bool {
    vector::contains(&admin_cap.permissions, &permission)
}

/// Get role from RoleCap
public fun get_role(role_cap: &RoleCap): String {
    role_cap.role
}

/// Get permissions from AdminCap
public fun get_permissions(admin_cap: &AdminCap): vector<String> {
    admin_cap.permissions
}

/// Check if address is owner
public fun is_owner(registry: &RoleRegistry, addr: address): bool {
    registry.owner == addr
}

// === Constants for Role Checking ===

public fun admin_role(): String {
    string::utf8(ADMIN_ROLE)
}

public fun minter_role(): String {
    string::utf8(MINTER_ROLE)
}

public fun marketplace_admin_role(): String {
    string::utf8(MARKETPLACE_ADMIN_ROLE)
}

public fun upgrader_role(): String {
    string::utf8(UPGRADER_ROLE)
}

// === Authorization Helpers ===

/// Assert that caller has owner capability
public fun assert_owner(_owner_cap: &OwnerCap) {
    // Just holding the OwnerCap proves ownership
}

/// Assert that caller has specific role
public fun assert_role(registry: &RoleRegistry, role: String, addr: address) {
    assert!(has_role(registry, role, addr), ENotAuthorized);
}

/// Assert that admin cap has specific permission
public fun assert_permission(admin_cap: &AdminCap, permission: String) {
    assert!(has_permission(admin_cap, permission), ENotAuthorized);
}

// === Test Functions ===

#[test_only]
public fun create_owner_cap_for_testing(ctx: &mut TxContext): OwnerCap {
    OwnerCap {
        id: object::new(ctx),
    }
}

#[test_only]
public fun create_role_registry_for_testing(ctx: &mut TxContext): RoleRegistry {
    RoleRegistry {
        id: object::new(ctx),
        owner: ctx.sender(),
        roles: table::new(ctx),
    }
}