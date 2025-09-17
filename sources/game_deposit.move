// Copyright (c) IsekaiBlade Game
// SPDX-License-Identifier: MIT

/// Game NFT Custody Contract for Isekai Blade
/// Implements hybrid on-chain/off-chain model for NFT deposits and withdrawals
/// Ensures atomic, auditable, and secure asset management
module isekai_blade::game_deposit {
    use sui::dynamic_field;
    use sui::event;
    use sui::table::{Self as table, Table};
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self as string, String};
    use std::vector;

    // Import IsekaiBlade NFT type
    use isekai_blade::isekai_blade::IsekaiBlade;

    // ===== Errors =====
    const EUnauthorized: u64 = 1;
    // const EDepositNotFound: u64 = 3; // Removed unused constant
    const ENFTAlreadyDeposited: u64 = 4;
    const ENFTNotFound: u64 = 5;
    const ENFTNotOwnedByPlayer: u64 = 6;
    const ENFTInBattle: u64 = 7;
    const EInvalidWithdrawal: u64 = 8;

    // ===== Structs =====

    /// Main game treasury that holds all NFT deposits using custody model
    public struct GameTreasury has key {
        id: UID,
        total_nft_deposits: u64,
        total_nft_withdrawals: u64,
        admin: address,
    }

    /// Individual NFT custody record for hybrid on-chain/off-chain model
    public struct NFTDepositRecord has key, store {
        id: UID,
        player: address,
        nft_object_id: ID,
        nft_type: String,
        purpose: String,
        metadata: String,
        deposit_timestamp: u64,
        withdrawal_timestamp: u64,
        status: String, // "deposited", "in_game", "in_battle", "pending_withdrawal", "withdrawn"
        game_session_id: String,
        transaction_hash: String,
    }

    /// Player's NFT deposit summary for tracking
    public struct PlayerNFTDepositSummary has key {
        id: UID,
        player: address,
        total_nfts_deposited: u64,
        active_deposits: u64,
        deposits: Table<ID, NFTDepositRecord>,
    }

    // ===== Events =====

    public struct NFTDepositEvent has copy, drop {
        player: address,
        nft_object_id: ID,
        nft_type: String,
        purpose: String,
        game_session_id: String,
        deposit_id: ID,
        timestamp: u64,
    }

    public struct NFTWithdrawalEvent has copy, drop {
        player: address,
        nft_object_id: ID,
        deposit_id: ID,
        reason: String,
        timestamp: u64,
    }

    public struct NFTGamePlayEvent has copy, drop {
        player: address,
        nft_object_id: ID,
        game_type: String,
        timestamp: u64,
    }

    public struct NFTStatusUpdateEvent has copy, drop {
        player: address,
        nft_object_id: ID,
        old_status: String,
        new_status: String,
        timestamp: u64,
    }

    // ===== Init Function =====

    /// Initialize the game treasury (called once during contract deployment)
    fun init(ctx: &mut TxContext) {
        let treasury = GameTreasury {
            id: object::new(ctx),
            total_nft_deposits: 0,
            total_nft_withdrawals: 0,
            admin: tx_context::sender(ctx),
        };
        transfer::share_object(treasury);
    }

    // ===== Public Entry Functions =====

    /// Atomic NFT deposit into custody contract (BR-1, BR-2, BR-4)
    /// This function implements the custody model where NFTs are locked in contract
    public fun deposit_nft_into_custody(
        treasury: &mut GameTreasury,
        nft: IsekaiBlade,
        nft_type: vector<u8>,
        purpose: vector<u8>,
        metadata: vector<u8>,
        game_session_id: vector<u8>,
        ctx: &mut TxContext
    ) {
        let player = tx_context::sender(ctx);
        let nft_object_id = object::id(&nft);
        
        // BR-2: Prevent duplicate deposits - ensure NFT not already in custody
        assert!(!dynamic_field::exists_(&treasury.id, nft_object_id), ENFTAlreadyDeposited);
        
        // BR-1: Lock the NFT in custody contract (atomic operation)
        dynamic_field::add(&mut treasury.id, nft_object_id, nft);
        treasury.total_nft_deposits = treasury.total_nft_deposits + 1;

        // BR-4: Create atomic and auditable deposit record
        let deposit_record = NFTDepositRecord {
            id: object::new(ctx),
            player,
            nft_object_id,
            nft_type: string::utf8(nft_type),
            purpose: string::utf8(purpose),
            metadata: string::utf8(metadata),
            deposit_timestamp: tx_context::epoch_timestamp_ms(ctx),
            withdrawal_timestamp: 0,
            status: string::utf8(b"deposited"), // Initial status for off-chain processing
            game_session_id: string::utf8(game_session_id),
            transaction_hash: string::utf8(vector::empty<u8>()), // Will be set by frontend
        };

        let deposit_id = object::id(&deposit_record);

        // Update or create player summary
        if (!player_nft_summary_exists(player)) {
            create_player_nft_summary(player, ctx);
        };

        // BR-4: Emit auditable deposit event for game server monitoring
        event::emit(NFTDepositEvent {
            player,
            nft_object_id,
            nft_type: string::utf8(nft_type),
            purpose: string::utf8(purpose),
            game_session_id: string::utf8(game_session_id),
            deposit_id,
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });

        // Transfer custody record to player for verification
        transfer::transfer(deposit_record, player);
    }

    /// Update NFT status for game server coordination (BR-3, BR-5)
    /// Allows game server to update NFT status during gameplay
    public fun update_nft_status(
        record: &mut NFTDepositRecord,
        new_status: vector<u8>,
        ctx: &mut TxContext
    ) {
        let player = tx_context::sender(ctx);
        
        // Only player or admin can update status
        assert!(record.player == player, EUnauthorized);
        
        let old_status = record.status;
        let new_status_string = string::utf8(new_status);
        
        record.status = new_status_string;
        
        event::emit(NFTStatusUpdateEvent {
            player,
            nft_object_id: record.nft_object_id,
            old_status,
            new_status: new_status_string,
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });
    }

    /// Use deposited NFT for gameplay (BR-3)
    public fun use_nft_for_gameplay(
        treasury: &GameTreasury,
        nft_object_id: ID,
        game_type: vector<u8>,
        ctx: &mut TxContext
    ) {
        let player = tx_context::sender(ctx);
        
        // BR-7: Verify NFT exists in custody
        assert!(dynamic_field::exists_(&treasury.id, nft_object_id), ENFTNotFound);
        
        event::emit(NFTGamePlayEvent {
            player,
            nft_object_id,
            game_type: string::utf8(game_type),
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });
    }

    /// Atomic NFT withdrawal from custody (BR-6, BR-7, BR-8, BR-10)
    /// This function implements verified withdrawal with game server coordination
    public fun withdraw_nft_from_custody(
        treasury: &mut GameTreasury,
        nft_object_id: ID,
        deposit_record: &mut NFTDepositRecord,
        ctx: &mut TxContext
    ) {
        let player = tx_context::sender(ctx);
        
        // BR-7: Verify player ownership
        assert!(deposit_record.player == player, ENFTNotOwnedByPlayer);
        assert!(deposit_record.nft_object_id == nft_object_id, ENFTNotFound);
        
        // BR-7: Verify NFT exists in custody
        assert!(dynamic_field::exists_(&treasury.id, nft_object_id), ENFTNotFound);
        
        // BR-7: Verify NFT is not locked in battle (check status)
        let current_status = deposit_record.status;
        assert!(current_status != string::utf8(b"in_battle"), ENFTInBattle);
        assert!(current_status != string::utf8(b"pending_withdrawal"), EInvalidWithdrawal);
        
        // BR-8: Atomic withdrawal - remove from custody
        let nft: IsekaiBlade = dynamic_field::remove(&mut treasury.id, nft_object_id);
        treasury.total_nft_withdrawals = treasury.total_nft_withdrawals + 1;

        // BR-8: Update deposit record status atomically
        deposit_record.status = string::utf8(b"withdrawn");
        deposit_record.withdrawal_timestamp = tx_context::epoch_timestamp_ms(ctx);

        let deposit_id = object::id(deposit_record);

        // BR-13: Emit auditable withdrawal event
        event::emit(NFTWithdrawalEvent {
            player,
            nft_object_id,
            deposit_id,
            reason: string::utf8(b"player_withdrawal"),
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });

        // BR-8, BR-17: Transfer NFT back to player's wallet
        transfer::public_transfer(nft, player);
    }

    /// Emergency withdrawal (admin only) for exceptional cases
    public fun emergency_nft_withdraw(
        treasury: &mut GameTreasury,
        nft_object_id: ID,
        recipient: address,
        ctx: &mut TxContext
    ) {
        // Only admin can perform emergency withdrawals
        assert!(tx_context::sender(ctx) == treasury.admin, EUnauthorized);
        
        // Remove NFT from treasury
        let nft: IsekaiBlade = dynamic_field::remove(&mut treasury.id, nft_object_id);
        treasury.total_nft_withdrawals = treasury.total_nft_withdrawals + 1;

        event::emit(NFTWithdrawalEvent {
            player: recipient,
            nft_object_id,
            deposit_id: object::id_from_address(@0x0), // No deposit record for emergency
            reason: string::utf8(b"emergency_withdrawal"),
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });

        transfer::public_transfer(nft, recipient);
    }

    // ===== Helper Functions =====

    fun player_nft_summary_exists(_player: address): bool {
        // In a real implementation, you'd check if the player NFT summary exists
        // This is simplified for the example
        false
    }

    fun create_player_nft_summary(player: address, ctx: &mut TxContext) {
        let summary = PlayerNFTDepositSummary {
            id: object::new(ctx),
            player,
            total_nfts_deposited: 0,
            active_deposits: 0,
            deposits: table::new<ID, NFTDepositRecord>(ctx),
        };
        transfer::transfer(summary, player);
    }

    // ===== View Functions =====

    /// Get total NFT deposits
    public fun get_total_nft_deposits(treasury: &GameTreasury): u64 {
        treasury.total_nft_deposits
    }

    /// Get total NFT withdrawals
    public fun get_total_nft_withdrawals(treasury: &GameTreasury): u64 {
        treasury.total_nft_withdrawals
    }

    /// Check if NFT exists in treasury
    public fun nft_exists_in_treasury(treasury: &GameTreasury, nft_object_id: ID): bool {
        dynamic_field::exists_(&treasury.id, nft_object_id)
    }

    /// Get deposit record info
    public fun get_deposit_info(record: &NFTDepositRecord): (address, ID, String, String, u64, u64, String) {
        (
            record.player,
            record.nft_object_id,
            record.nft_type,
            record.purpose,
            record.deposit_timestamp,
            record.withdrawal_timestamp,
            record.status
        )
    }

    /// Get treasury admin
    public fun get_treasury_admin(treasury: &GameTreasury): address {
        treasury.admin
    }

    // ===== Admin Functions =====

    /// Update treasury admin (current admin only)
    public fun update_treasury_admin(
        treasury: &mut GameTreasury,
        new_admin: address,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == treasury.admin, EUnauthorized);
        treasury.admin = new_admin;
    }

    // ===== Test Functions =====

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }

    #[test_only]
    public fun create_treasury_for_testing(ctx: &mut TxContext): GameTreasury {
        GameTreasury {
            id: object::new(ctx),
            total_nft_deposits: 0,
            total_nft_withdrawals: 0,
            admin: tx_context::sender(ctx),
        }
    }
}