/usr/local/bin/pnpm run testnet:deploy

> backend@0.0.0 testnet:deploy /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend
> sui client switch --env testnet && cd move/isekai_blade && sui client publish --gas-budget 2000000000

[warning] Client/Server api version mismatch, client api version : 1.55.0, server api version : 1.56.1
Active environment switched to [testnet]
[warning] Client/Server api version mismatch, client api version : 1.55.0, server api version : 1.56.1
[Note]: Dependency sources are no longer verified automatically during publication and upgrade. You can pass the `--verify-deps` option if you would like to verify them as part of publication or upgrade.
[note] Dependencies on Bridge, MoveStdlib, Sui, and SuiSystem are automatically added, but this feature is disabled for your package because you have explicitly included dependencies on Sui. Consider removing these dependencies from Move.toml.
UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 5 (delta 0), reused 5 (delta 0), pack-reused 0 (from 0)
Receiving objects: 100% (5/5), 1.12 KiB | 1.12 MiB/s, done.
From https://github.com/MystenLabs/sui
c73a8304..aa4a6f69  akichidis/latency-check-server                       -> origin/akichidis/latency-check-server
2e28c245..de64b620  graphql-alt-transaction-effects-input-output-objects -> origin/graphql-alt-transaction-effects-input-output-objects
92ef25a8..39d1287e  ml/wrap-up-legacy-lockfile                           -> origin/ml/wrap-up-legacy-lockfile
+ a51cff4d...2a7cbd85 transaction_filter_sent_address                      -> origin/transaction_filter_sent_address  (forced update)
  INCLUDING DEPENDENCY Sui
  INCLUDING DEPENDENCY MoveStdlib
  BUILDING isekai_blade
  warning[W02021]: duplicate alias
  ┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:8:23
  │
  8 │     use sui::object::{Self, UID, ID};
  │                       ^^^^ Unnecessary alias 'object' for module 'sui::object'. This alias is provided by default
  │
  = This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:8:29
│
8 │     use sui::object::{Self, UID, ID};
│                             ^^^ Unnecessary alias 'UID' for module member 'sui::object::UID'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:8:34
│
8 │     use sui::object::{Self, UID, ID};
│                                  ^^ Unnecessary alias 'ID' for module member 'sui::object::ID'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:9:14
│
9 │     use sui::transfer;
│              ^^^^^^^^ Unnecessary alias 'transfer' for module 'sui::transfer'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:10:27
│
10 │     use sui::tx_context::{Self, TxContext};
│                           ^^^^ Unnecessary alias 'tx_context' for module 'sui::tx_context'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:10:33
│
10 │     use sui::tx_context::{Self, TxContext};
│                                 ^^^^^^^^^ Unnecessary alias 'TxContext' for module member 'sui::tx_context::TxContext'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:15:14
│
15 │     use std::vector;
│              ^^^^^^ Unnecessary alias 'vector' for module 'std::vector'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:22:11
│
22 │     const EDepositNotFound: u64 = 3;
│           ^^^^^^^^^^^^^^^^ The constant 'EDepositNotFound' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99010]: unnecessary `entry` on a `public` function
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:115:12
│
115 │     public entry fun deposit_nft_into_custody(
│            ^^^^^ `entry` on `public` functions limits composability as it adds restrictions, e.g. the type of each return value must have `drop`. `entry` on `public` is only meaningful in niche scenarios.
│
= `public` functions can be called from PTBs. `entry` can be used to allow non-`public` functions to be called from PTBs, but it adds restrictions on the usage of input arguments and on the type of return values. Unless this `public` function interacts with an intricate set of other `entry` functions, the `entry` modifier should be removed.
= This warning can be suppressed with '#[allow(lint(public_entry))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99010]: unnecessary `entry` on a `public` function
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:173:12
│
173 │     public entry fun update_nft_status(
│            ^^^^^ `entry` on `public` functions limits composability as it adds restrictions, e.g. the type of each return value must have `drop`. `entry` on `public` is only meaningful in niche scenarios.
│
= `public` functions can be called from PTBs. `entry` can be used to allow non-`public` functions to be called from PTBs, but it adds restrictions on the usage of input arguments and on the type of return values. Unless this `public` function interacts with an intricate set of other `entry` functions, the `entry` modifier should be removed.
= This warning can be suppressed with '#[allow(lint(public_entry))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99010]: unnecessary `entry` on a `public` function
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:198:12
│
198 │     public entry fun use_nft_for_gameplay(
│            ^^^^^ `entry` on `public` functions limits composability as it adds restrictions, e.g. the type of each return value must have `drop`. `entry` on `public` is only meaningful in niche scenarios.
│
= `public` functions can be called from PTBs. `entry` can be used to allow non-`public` functions to be called from PTBs, but it adds restrictions on the usage of input arguments and on the type of return values. Unless this `public` function interacts with an intricate set of other `entry` functions, the `entry` modifier should be removed.
= This warning can be suppressed with '#[allow(lint(public_entry))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99010]: unnecessary `entry` on a `public` function
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:219:12
│
219 │     public entry fun withdraw_nft_from_custody(
│            ^^^^^ `entry` on `public` functions limits composability as it adds restrictions, e.g. the type of each return value must have `drop`. `entry` on `public` is only meaningful in niche scenarios.
│
= `public` functions can be called from PTBs. `entry` can be used to allow non-`public` functions to be called from PTBs, but it adds restrictions on the usage of input arguments and on the type of return values. Unless this `public` function interacts with an intricate set of other `entry` functions, the `entry` modifier should be removed.
= This warning can be suppressed with '#[allow(lint(public_entry))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99010]: unnecessary `entry` on a `public` function
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:263:12
│
263 │     public entry fun emergency_nft_withdraw(
│            ^^^^^ `entry` on `public` functions limits composability as it adds restrictions, e.g. the type of each return value must have `drop`. `entry` on `public` is only meaningful in niche scenarios.
│
= `public` functions can be called from PTBs. `entry` can be used to allow non-`public` functions to be called from PTBs, but it adds restrictions on the usage of input arguments and on the type of return values. Unless this `public` function interacts with an intricate set of other `entry` functions, the `entry` modifier should be removed.
= This warning can be suppressed with '#[allow(lint(public_entry))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99010]: unnecessary `entry` on a `public` function
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/game_deposit.move:344:12
│
344 │     public entry fun update_treasury_admin(
│            ^^^^^ `entry` on `public` functions limits composability as it adds restrictions, e.g. the type of each return value must have `drop`. `entry` on `public` is only meaningful in niche scenarios.
│
= `public` functions can be called from PTBs. `entry` can be used to allow non-`public` functions to be called from PTBs, but it adds restrictions on the usage of input arguments and on the type of return values. Unless this `public` function interacts with an intricate set of other `entry` functions, the `entry` modifier should be removed.
= This warning can be suppressed with '#[allow(lint(public_entry))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:8:19
│
8 │ use std::option::{Self, Option};
│                   ^^^^ Unnecessary alias 'option' for module 'std::option'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:8:25
│
8 │ use std::option::{Self, Option};
│                         ^^^^^^ Unnecessary alias 'Option' for module member 'std::option::Option'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:9:10
│
9 │ use std::vector;
│          ^^^^^^ Unnecessary alias 'vector' for module 'std::vector'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:10:19
│
10 │ use sui::object::{Self, UID, ID};
│                   ^^^^ Unnecessary alias 'object' for module 'sui::object'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:10:25
│
10 │ use sui::object::{Self, UID, ID};
│                         ^^^ Unnecessary alias 'UID' for module member 'sui::object::UID'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:10:30
│
10 │ use sui::object::{Self, UID, ID};
│                              ^^ Unnecessary alias 'ID' for module member 'sui::object::ID'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:11:10
│
11 │ use sui::transfer;
│          ^^^^^^^^ Unnecessary alias 'transfer' for module 'sui::transfer'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:12:23
│
12 │ use sui::tx_context::{Self, TxContext};
│                       ^^^^ Unnecessary alias 'tx_context' for module 'sui::tx_context'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:12:29
│
12 │ use sui::tx_context::{Self, TxContext};
│                             ^^^^^^^^^ Unnecessary alias 'TxContext' for module member 'sui::tx_context::TxContext'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:21:32
│
21 │ use isekai_blade::collection::{Self, CollectionStats};
│                                ^^^^ Unused 'use' of alias 'collection'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:21:38
│
21 │ use isekai_blade::collection::{Self, CollectionStats};
│                                      ^^^^^^^^^^^^^^^ Unused 'use' of alias 'CollectionStats'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:36:7
│
36 │ const SWORD_TYPE: u8 = 1;
│       ^^^^^^^^^^ The constant 'SWORD_TYPE' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:37:7
│
37 │ const SHIELD_TYPE: u8 = 2;
│       ^^^^^^^^^^^ The constant 'SHIELD_TYPE' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:38:7
│
38 │ const ARMOR_TYPE: u8 = 3;
│       ^^^^^^^^^^ The constant 'ARMOR_TYPE' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:39:7
│
39 │ const ACCESSORY_TYPE: u8 = 4;
│       ^^^^^^^^^^^^^^ The constant 'ACCESSORY_TYPE' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:52:7
│
52 │ const EUnauthorized: u64 = 9;
│       ^^^^^^^^^^^^^ The constant 'EUnauthorized' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:73:7
│
73 │ const TOTAL_SUPPLY: u64 = 10000; // Total planned NFTs
│       ^^^^^^^^^^^^ The constant 'TOTAL_SUPPLY' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:77:7
│
77 │ const FOURTH_QUARTER: u64 = 10000; // 75-100%
│       ^^^^^^^^^^^^^^ The constant 'FOURTH_QUARTER' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09008]: unused function
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:597:5
│
597 │ fun log_unauthorized_access(user: address, function_name: String, ctx: &TxContext) {
│     ^^^^^^^^^^^^^^^^^^^^^^^ The non-'public', non-'entry' function 'log_unauthorized_access' is never called. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_function)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:1244:7
│
1244 │ const ECombineNotAllowed: u64 = 9;
│       ^^^^^^^^^^^^^^^^^^ The constant 'ECombineNotAllowed' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99006]: Risky use of 'sui::random'
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/isekai_blade.move:2029:8
│
2029 │     r: &Random,
│        ^^^^^^^ 'public' function 'whitelist_mint' accepts 'Random' as a parameter
│
= Functions that accept 'sui::random::Random' as a parameter might be abused by attackers by inspecting the results of randomness
= Non-public functions are preferred
= This warning can be suppressed with '#[allow(lint(public_random))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:8:10
│
8 │ use std::vector;
│          ^^^^^^ Unnecessary alias 'vector' for module 'std::vector'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:10:19
│
10 │ use sui::object::{Self, UID};
│                   ^^^^ Unnecessary alias 'object' for module 'sui::object'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:10:19
│
10 │ use sui::object::{Self, UID};
│                   ^^^^ Unused 'use' of alias 'object'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:10:25
│
10 │ use sui::object::{Self, UID};
│                         ^^^ Unnecessary alias 'UID' for module member 'sui::object::UID'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:10:25
│
10 │ use sui::object::{Self, UID};
│                         ^^^ Unused 'use' of alias 'UID'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:11:18
│
11 │ use sui::table::{Self, Table};
│                  ^^^^ Unused 'use' of alias 'table'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:11:24
│
11 │ use sui::table::{Self, Table};
│                        ^^^^^ Unused 'use' of alias 'Table'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:12:22
│
12 │ use sui::tx_context::TxContext;
│                      ^^^^^^^^^ Unnecessary alias 'TxContext' for module member 'sui::tx_context::TxContext'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:12:22
│
12 │ use sui::tx_context::TxContext;
│                      ^^^^^^^^^ Unused 'use' of alias 'TxContext'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/image_generator.move:88:5
│
88 │     nft_address: address,
│     ^^^^^^^^^^^ Unused parameter 'nft_address'. Consider removing or prefixing with an underscore: '_nft_address'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:14:36
│
14 │ use isekai_blade::access_control::{OwnerCap, AdminCap};
│                                    ^^^^^^^^ Unused 'use' of alias 'OwnerCap'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:26:7
│
26 │ const EInvalidListingType: u64 = 7;
│       ^^^^^^^^^^^^^^^^^^^ The constant 'EInvalidListingType' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:33:7
│
33 │ const MIN_BID_INCREMENT_BPS: u64 = 500; // 5%
│       ^^^^^^^^^^^^^^^^^^^^^ The constant 'MIN_BID_INCREMENT_BPS' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:38:7
│
38 │ const LISTING_TYPE_AUCTION: u8 = 1;
│       ^^^^^^^^^^^^^^^^^^^^ The constant 'LISTING_TYPE_AUCTION' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:39:7
│
39 │ const LISTING_TYPE_BUNDLE: u8 = 2;
│       ^^^^^^^^^^^^^^^^^^^ The constant 'LISTING_TYPE_BUNDLE' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:96:5
│
96 │     admin: address,
│     ^^^^^ The 'admin' field of the 'MarketplaceConfig' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:97:5
│
97 │     fee_recipient: address,
│     ^^^^^^^^^^^^^ The 'fee_recipient' field of the 'MarketplaceConfig' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:98:5
│
98 │     marketplace_fee: u64,
│     ^^^^^^^^^^^^^^^ The 'marketplace_fee' field of the 'MarketplaceConfig' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:99:5
│
99 │     min_listing_duration: u64,
│     ^^^^^^^^^^^^^^^^^^^^ The 'min_listing_duration' field of the 'MarketplaceConfig' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:100:5
│
100 │     max_listing_duration: u64,
│     ^^^^^^^^^^^^^^^^^^^^ The 'max_listing_duration' field of the 'MarketplaceConfig' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:101:5
│
101 │     min_auction_duration: u64,
│     ^^^^^^^^^^^^^^^^^^^^ The 'min_auction_duration' field of the 'MarketplaceConfig' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:102:5
│
102 │     max_auction_duration: u64,
│     ^^^^^^^^^^^^^^^^^^^^ The 'max_auction_duration' field of the 'MarketplaceConfig' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:166:5
│
166 │     bundle_id: ID,
│     ^^^^^^^^^ The 'bundle_id' field of the 'BundleSold' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:167:5
│
167 │     seller: address,
│     ^^^^^^ The 'seller' field of the 'BundleSold' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:168:5
│
168 │     buyer: address,
│     ^^^^^ The 'buyer' field of the 'BundleSold' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:169:5
│
169 │     item_count: u64,
│     ^^^^^^^^^^ The 'item_count' field of the 'BundleSold' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:170:5
│
170 │     total_price: u64,
│     ^^^^^^^^^^^ The 'total_price' field of the 'BundleSold' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:179:5
│
179 │     fee_recipient: address,
│     ^^^^^^^^^^^^^ Unused parameter 'fee_recipient'. Consider removing or prefixing with an underscore: '_fee_recipient'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:423:5
│
423 │     ctx: &mut TxContext
│     ^^^ Unused parameter 'ctx'. Consider removing or prefixing with an underscore: '_ctx'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:438:13
│
438 │         let marketplace_fee = (sale_price * marketplace.marketplace_fee) / BASIS_POINTS;
│             ^^^^^^^^^^^^^^^ Unused local variable 'marketplace_fee'. Consider removing or prefixing with an underscore: '_marketplace_fee'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:439:13
│
439 │         let royalty_amount = collection::calculate_royalty(collection, sale_price);
│             ^^^^^^^^^^^^^^ Unused local variable 'royalty_amount'. Consider removing or prefixing with an underscore: '_royalty_amount'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:536:5
│
536 │     escrow: &mut Table<ID, IsekaiBlade>,
│     ^^^^^^ Unused parameter 'escrow'. Consider removing or prefixing with an underscore: '_escrow'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:571:5
│
571 │     escrow: &mut Table<ID, IsekaiBlade>,
│     ^^^^^^ Unused parameter 'escrow'. Consider removing or prefixing with an underscore: '_escrow'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:592:9
│
592 │     let seller_amount = price - marketplace_fee - royalty_amount;
│         ^^^^^^^^^^^^^ Unused local variable 'seller_amount'. Consider removing or prefixing with an underscore: '_seller_amount'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99001]: non-composable transfer to sender
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:603:5
│
569 │ public fun buy_item_safe(
│            ------------- Returning an object from a function, allows a caller to use the object and enables composability via programmable transactions.
·
603 │     transfer::public_transfer(nft, ctx.sender());
│     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
│     │                              │
│     │                              Transaction sender address coming from here
│     Transfer of an object to transaction sender address
│
= This warning can be suppressed with '#[allow(lint(self_transfer))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:622:5
│
622 │     escrow: &mut Table<ID, IsekaiBlade>,
│     ^^^^^^ Unused parameter 'escrow'. Consider removing or prefixing with an underscore: '_escrow'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[Lint W99001]: non-composable transfer to sender
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/marketplace.move:638:5
│
620 │ public fun delist_item_safe(
│            ---------------- Returning an object from a function, allows a caller to use the object and enables composability via programmable transactions.
·
638 │     transfer::public_transfer(nft, ctx.sender());
│     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
│     │                              │
│     │                              Transaction sender address coming from here
│     Transfer of an object to transaction sender address
│
= This warning can be suppressed with '#[allow(lint(self_transfer))]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/access_control.move:13:7
│
13 │ const ERoleAlreadyExists: u64 = 1;
│       ^^^^^^^^^^^^^^^^^^ The constant 'ERoleAlreadyExists' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/access_control.move:15:7
│
15 │ const EInvalidRole: u64 = 3;
│       ^^^^^^^^^^^^ The constant 'EInvalidRole' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/attributes_chain.move:10:19
│
10 │ use std::option::{Self, Option};
│                   ^^^^ Unnecessary alias 'option' for module 'std::option'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/attributes_chain.move:10:25
│
10 │ use std::option::{Self, Option};
│                         ^^^^^^ Unnecessary alias 'Option' for module member 'std::option::Option'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/attributes_chain.move:18:7
│
18 │ const EMissingRequiredAttribute: u64 = 4;
│       ^^^^^^^^^^^^^^^^^^^^^^^^^ The constant 'EMissingRequiredAttribute' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/attributes_chain.move:62:5
│
62 │     _schemas: Table<String, ID>,
│     ^^^^^^^^ The '_schemas' field of the 'SchemaRegistry' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09009]: unused struct field
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/attributes_chain.move:63:5
│
63 │     _latest_versions: Table<String, u64>,
│     ^^^^^^^^^^^^^^^^ The '_latest_versions' field of the 'SchemaRegistry' type is unused
│
= This warning can be suppressed with '#[allow(unused_field)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W04037]: deprecated usage
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/attributes_chain.move:321:14
│
321 │     vec_map::size(&chain.attributes)
│              ^^^^ The function 'sui::vec_map::size' is deprecated: Renamed to `length` for consistency.
│
= This warning can be suppressed with '#[allow(deprecated_usage)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/attributes_chain.move:407:7
│
407 │ const CHARACTER_ITEM_TYPE: u8 = 0;
│       ^^^^^^^^^^^^^^^^^^^ The constant 'CHARACTER_ITEM_TYPE' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:10:26
│
10 │ use sui::package::{Self, Publisher};
│                          ^^^^^^^^^ Unused 'use' of alias 'Publisher'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:12:19
│
12 │ use std::option::{Self, Option};
│                   ^^^^ Unnecessary alias 'option' for module 'std::option'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09001]: unused alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:12:19
│
12 │ use std::option::{Self, Option};
│                   ^^^^ Unused 'use' of alias 'option'. Consider removing it
│
= This warning can be suppressed with '#[allow(unused_use)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W02021]: duplicate alias
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:12:25
│
12 │ use std::option::{Self, Option};
│                         ^^^^^^ Unnecessary alias 'Option' for module member 'std::option::Option'. This alias is provided by default
│
= This warning can be suppressed with '#[allow(duplicate_alias)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:20:7
│
20 │ const EInvalidMetadata: u64 = 3;
│       ^^^^^^^^^^^^^^^^ The constant 'EInvalidMetadata' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:21:7
│
21 │ const ECollectionNotFound: u64 = 4;
│       ^^^^^^^^^^^^^^^^^^^ The constant 'ECollectionNotFound' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09011]: unused constant
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:24:7
│
24 │ const TOKEN_VERSION: u64 = 1;
│       ^^^^^^^^^^^^^ The constant 'TOKEN_VERSION' is never used. Consider removing it.
│
= This warning can be suppressed with '#[allow(unused_const)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:451:64
│
451 │ public fun lock_to_game(token: &mut IsekaiBlade, locked: bool, ctx: &mut TxContext) {
│                                                                ^^^ Unused parameter 'ctx'. Consider removing or prefixing with an underscore: '_ctx'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

warning[W09002]: unused variable
┌─ /Users/sonnt/WORKSPACE/SUI/isekai-blade-contract-stable/packages/backend/move/isekai_blade/sources/nft_token.move:559:17
│
559 │             let attr = attributes_chain::get_attribute(&token.attributes, name);
│                 ^^^^ Unused local variable 'attr'. Consider removing or prefixing with an underscore: '_attr'
│
= This warning can be suppressed with '#[allow(unused_variable)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

Please report feedback on the linter warnings at https://forums.sui.io

Total number of linter warnings suppressed: 10 (unique lints: 2)
Skipping dependency verification
Transaction Digest: DtgzM8uBh5Zz7XkAB6mqLpEKmDmV5fULbqLZc8ZvHwyd
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                             │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                   │
│ Gas Owner: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                │
│ Gas Budget: 2000000000 MIST                                                                                   │
│ Gas Price: 1000 MIST                                                                                         │
│ Gas Payment:                                                                                                 │
│  ┌──                                                                                                         │
│  │ ID: 0x45b68b707eeb7e79fccc42315a3a75792eac9de617377d0b624c7741beeae268                                    │
│  │ Version: 563458047                                                                                        │
│  │ Digest: 9TqwGWCNE6Qpy642BDNXc9AE9pMMyjWnm9SG2gAsy8ge                                                      │
│  └──                                                                                                         │
│                                                                                                              │
│ Transaction Kind: Programmable                                                                               │
│ ╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                                            │ │
│ ├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Pure Arg: Type: address, Value: "0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39" │ │
│ ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭─────────────────────────────────────────────────────────────────────────╮                                  │
│ │ Commands                                                                │                                  │
│ ├─────────────────────────────────────────────────────────────────────────┤                                  │
│ │ 0  Publish:                                                             │                                  │
│ │  ┌                                                                      │                                  │
│ │  │ Dependencies:                                                        │                                  │
│ │  │   0x0000000000000000000000000000000000000000000000000000000000000001 │                                  │
│ │  │   0x0000000000000000000000000000000000000000000000000000000000000002 │                                  │
│ │  └                                                                      │                                  │
│ │                                                                         │                                  │
│ │ 1  TransferObjects:                                                     │                                  │
│ │  ┌                                                                      │                                  │
│ │  │ Arguments:                                                           │                                  │
│ │  │   Result 0                                                           │                                  │
│ │  │ Address: Input  0                                                    │                                  │
│ │  └                                                                      │                                  │
│ ╰─────────────────────────────────────────────────────────────────────────╯                                  │
│                                                                                                              │
│ Signatures:                                                                                                  │
│    J5vbs6PQZDZSwaq4HMlKx7hCOS57txzE48NLHKkToQ/nvG21I2+vu39cxT1SaKanSD8Hj2y7XNMbd1dDadNODw==                  │
│                                                                                                              │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: DtgzM8uBh5Zz7XkAB6mqLpEKmDmV5fULbqLZc8ZvHwyd                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 852                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x184b00542718b9952c7da7b0c64e976e49515ed139be4c659fa41afedfc4071e                         │
│  │ Owner: Shared( 563458048 )                                                                     │
│  │ Version: 563458048                                                                             │
│  │ Digest: 8XRyj3hwGXmkNSoB8Gr5mM7bRiGvKqT2CDXjv7x2qRxo                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x1e14d895f64a53ebea8e68460b25621bd4302893c89231fcd1b6bb145d0d8472                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: 76ZxzTtvsgh94bmnPK7u5eVxJDgWxSd5BEZwEytbPfh8                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x270eb416a4bc1b77feea747ee0cca81f567b7a21bfbae38a09a9b5587480d6c0                         │
│  │ Owner: Shared( 563458048 )                                                                     │
│  │ Version: 563458048                                                                             │
│  │ Digest: DmhWkQyEyTNxuNpsRVRjoaVRw55SKWxzYdn4gB6pVL8A                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x37a879222e2dc0253d26824be032111e6798c2236a3e66deba1f52c1b0708aa7                         │
│  │ Owner: Shared( 563458048 )                                                                     │
│  │ Version: 563458048                                                                             │
│  │ Digest: HmNYA2qj1MQM1fATLzXFESPp6Hw9azqFf7ZRtxrs6b3f                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x74504022307520453fc9c37f81d9a7a731188c53d5fa432738bce7e7ed225988                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: H2EdtqTKLq6yUMWjx7zFcMeJkAk8svjJFM6iiL7LPmFW                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xb869b2d81cf11e5ad529ca2aaf144e4c12365229ace191d54bace6e201c2e3ac                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: Bu8mbNWK9HbhVUW8S34MiWocYXDYNLYJBbUMMGLAw7r5                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xbfef3fa5396a54b0c2a55040b91a3c086bcdfbfefe19544cab296226ad3b1bd1                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: 4Kvvghkw74pm98vDmsB9VTFBUCvzf1vbgehdcHt4Ejx2                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xc55fcc3943a73150975c4d605675e759a876ff6466363bf48f65cb43d893163d                         │
│  │ Owner: Shared( 563458048 )                                                                     │
│  │ Version: 563458048                                                                             │
│  │ Digest: Ce522V47XuDu2SpxoBQRSuzLcSTDFVnh1LMBJnAiEjaM                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xcefbd12ffb5204ba6b627170c2644961e32006ddfbb43258dbcb7b271ded1fdb                         │
│  │ Owner: Shared( 563458048 )                                                                     │
│  │ Version: 563458048                                                                             │
│  │ Digest: 4JmMDA9Pg1GiaD5FHHNtKZBq8gM4NL9XUt5nKgpJVN2i                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xdbe23742370a8bb232dbfb8d9bb15e1d55bf9225e50d1252a8eeab4c7d8539e2                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: DtnSanLCviUjU4fAK8sbbRaGQRBrehkziutvshSkVo1W                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xecff183718c1ac01ee2569171431f66eebd916a2cbcad2e1dec578270153579b                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: 7TuZ3dWqQEpN6V8gmcj6o9fwbpy5JRmuHs1cJVoogiG9                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e                         │
│  │ Owner: Immutable                                                                               │
│  │ Version: 1                                                                                     │
│  │ Digest: 58LuztGYHhKoXW2LYFjm6GmpKWUSS5SRCYGHSn3LNGhY                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xf76fdc5a912c3e4f9774a7d99097d55940a3c34477d121a9d8efe97417d5be47                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: 2beQCrc8P19meRKyP2BAfFasdcgkyjA9x5vfApanNBhC                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xfe1b487e7f7f18e213d41f11201cf8a1ae1093aafa36b2d9c2a40e427d3d9083                         │
│  │ Owner: Shared( 563458048 )                                                                     │
│  │ Version: 563458048                                                                             │
│  │ Digest: CVSxxCvDtUg8hpzwS4nphxTNJhbiDKN8j3eKZLSxZ6Uq                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x45b68b707eeb7e79fccc42315a3a75792eac9de617377d0b624c7741beeae268                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: Pv8mP6QzHF1mnyZNr2fMzhPr6rLU6UzWcuggFTGHbWH                                            │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0x45b68b707eeb7e79fccc42315a3a75792eac9de617377d0b624c7741beeae268                         │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ Version: 563458048                                                                             │
│  │ Digest: Pv8mP6QzHF1mnyZNr2fMzhPr6rLU6UzWcuggFTGHbWH                                            │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 374208800 MIST                                                                   │
│    Computation Cost: 4000000 MIST                                                                 │
│    Storage Rebate: 978120 MIST                                                                    │
│    Non-refundable Storage Fee: 9880 MIST                                                          │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    D2X3J8i6YS7m767iYjWEq3i23mAGJGTZu35qtAmjNB4B                                                   │
│    Eo5mFY7r6nVSjifLcz1dfKRdHkGCxhSC3qYk12TPWMZP                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                                                  │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                                                      │
│  │ EventID: DtgzM8uBh5Zz7XkAB6mqLpEKmDmV5fULbqLZc8ZvHwyd:0                                                                                │
│  │ PackageID: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e                                                          │
│  │ Transaction Module: isekai_blade                                                                                                       │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                             │
│  │ EventType: 0x2::display::DisplayCreated<0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::IsekaiBlade> │
│  │ ParsedJSON:                                                                                                                            │
│  │   ┌────┬────────────────────────────────────────────────────────────────────┐                                                          │
│  │   │ id │ 0x1e14d895f64a53ebea8e68460b25621bd4302893c89231fcd1b6bb145d0d8472 │                                                          │
│  │   └────┴────────────────────────────────────────────────────────────────────┘                                                          │
│  └──                                                                                                                                      │
│  ┌──                                                                                                                                      │
│  │ EventID: DtgzM8uBh5Zz7XkAB6mqLpEKmDmV5fULbqLZc8ZvHwyd:1                                                                                │
│  │ PackageID: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e                                                          │
│  │ Transaction Module: isekai_blade                                                                                                       │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                             │
│  │ EventType: 0x2::display::VersionUpdated<0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::IsekaiBlade> │
│  │ ParsedJSON:                                                                                                                            │
│  │   ┌─────────┬──────────┬───────┬─────────────────────────────────────────────────┐                                                     │
│  │   │ fields  │ contents │ key   │ name                                            │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {name}                                          │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ description                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {description}                                   │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ image_url                                       │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {image_url}                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ project_url                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ https://marketplace.isekaiblade.com             │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ creator                                         │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ IsekaiBlade                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ rarity                                          │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {rarity}                                        │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ level                                           │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {level}                                         │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ item_type                                       │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {item_type}                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ attack                                          │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {attack}                                        │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ defense                                         │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {defense}                                       │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ magic                                           │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {magic}                                         │                                                     │
│  │   ├─────────┼──────────┴───────┴─────────────────────────────────────────────────┤                                                     │
│  │   │ id      │ 0x1e14d895f64a53ebea8e68460b25621bd4302893c89231fcd1b6bb145d0d8472 │                                                     │
│  │   ├─────────┼────────────────────────────────────────────────────────────────────┤                                                     │
│  │   │ version │ 1                                                                  │                                                     │
│  │   └─────────┴────────────────────────────────────────────────────────────────────┘                                                     │
│  └──                                                                                                                                      │
│  ┌──                                                                                                                                      │
│  │ EventID: DtgzM8uBh5Zz7XkAB6mqLpEKmDmV5fULbqLZc8ZvHwyd:2                                                                                │
│  │ PackageID: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e                                                          │
│  │ Transaction Module: nft_token                                                                                                          │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                             │
│  │ EventType: 0x2::display::DisplayCreated<0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::nft_token::IsekaiBlade>    │
│  │ ParsedJSON:                                                                                                                            │
│  │   ┌────┬────────────────────────────────────────────────────────────────────┐                                                          │
│  │   │ id │ 0xecff183718c1ac01ee2569171431f66eebd916a2cbcad2e1dec578270153579b │                                                          │
│  │   └────┴────────────────────────────────────────────────────────────────────┘                                                          │
│  └──                                                                                                                                      │
│  ┌──                                                                                                                                      │
│  │ EventID: DtgzM8uBh5Zz7XkAB6mqLpEKmDmV5fULbqLZc8ZvHwyd:3                                                                                │
│  │ PackageID: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e                                                          │
│  │ Transaction Module: nft_token                                                                                                          │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                             │
│  │ EventType: 0x2::display::VersionUpdated<0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::nft_token::IsekaiBlade>    │
│  │ ParsedJSON:                                                                                                                            │
│  │   ┌─────────┬──────────┬───────┬─────────────────────────────────────────────────┐                                                     │
│  │   │ fields  │ contents │ key   │ name                                            │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {name}                                          │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ description                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {description}                                   │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ image_url                                       │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {image_url}                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ external_url                                    │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {external_url}                                  │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ animation_url                                   │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {animation_url}                                 │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ project_url                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ https://marketplace.isekaiblade.com             │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ creator                                         │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {creator}                                       │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ rarity                                          │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {rarity}                                        │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ item_type                                       │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {item_type}                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ attributes                                      │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {attributes}                                    │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ collection_id                                   │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {collection_id}                                 │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ minted_at                                       │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {minted_at}                                     │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ key   │ upgrade_count                                   │                                                     │
│  │   │         │          ├───────┼─────────────────────────────────────────────────┤                                                     │
│  │   │         │          │ value │ {upgrade_count}                                 │                                                     │
│  │   ├─────────┼──────────┴───────┴─────────────────────────────────────────────────┤                                                     │
│  │   │ id      │ 0xecff183718c1ac01ee2569171431f66eebd916a2cbcad2e1dec578270153579b │                                                     │
│  │   ├─────────┼────────────────────────────────────────────────────────────────────┤                                                     │
│  │   │ version │ 1                                                                  │                                                     │
│  │   └─────────┴────────────────────────────────────────────────────────────────────┘                                                     │
│  └──                                                                                                                                      │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                         │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                                       │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0x184b00542718b9952c7da7b0c64e976e49515ed139be4c659fa41afedfc4071e                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Shared( 563458048 )                                                                                                          │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::WhitelistRegistry                     │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: 8XRyj3hwGXmkNSoB8Gr5mM7bRiGvKqT2CDXjv7x2qRxo                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0x1e14d895f64a53ebea8e68460b25621bd4302893c89231fcd1b6bb145d0d8472                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0x2::display::Display<0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::IsekaiBlade>    │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: 76ZxzTtvsgh94bmnPK7u5eVxJDgWxSd5BEZwEytbPfh8                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0x270eb416a4bc1b77feea747ee0cca81f567b7a21bfbae38a09a9b5587480d6c0                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Shared( 563458048 )                                                                                                          │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::MintCounter                           │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: DmhWkQyEyTNxuNpsRVRjoaVRw55SKWxzYdn4gB6pVL8A                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0x37a879222e2dc0253d26824be032111e6798c2236a3e66deba1f52c1b0708aa7                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Shared( 563458048 )                                                                                                          │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::NFTEscrow                             │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: HmNYA2qj1MQM1fATLzXFESPp6Hw9azqFf7ZRtxrs6b3f                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0x74504022307520453fc9c37f81d9a7a731188c53d5fa432738bce7e7ed225988                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0x2::package::Publisher                                                                                                 │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: H2EdtqTKLq6yUMWjx7zFcMeJkAk8svjJFM6iiL7LPmFW                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xb869b2d81cf11e5ad529ca2aaf144e4c12365229ace191d54bace6e201c2e3ac                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0x2::package::UpgradeCap                                                                                                │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: Bu8mbNWK9HbhVUW8S34MiWocYXDYNLYJBbUMMGLAw7r5                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xbfef3fa5396a54b0c2a55040b91a3c086bcdfbfefe19544cab296226ad3b1bd1                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::GovernanceCap                         │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: 4Kvvghkw74pm98vDmsB9VTFBUCvzf1vbgehdcHt4Ejx2                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xc55fcc3943a73150975c4d605675e759a876ff6466363bf48f65cb43d893163d                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Shared( 563458048 )                                                                                                          │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::ContractVersion                       │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: Ce522V47XuDu2SpxoBQRSuzLcSTDFVnh1LMBJnAiEjaM                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xcefbd12ffb5204ba6b627170c2644961e32006ddfbb43258dbcb7b271ded1fdb                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Shared( 563458048 )                                                                                                          │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::Marketplace                           │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: 4JmMDA9Pg1GiaD5FHHNtKZBq8gM4NL9XUt5nKgpJVN2i                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xdbe23742370a8bb232dbfb8d9bb15e1d55bf9225e50d1252a8eeab4c7d8539e2                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0x2::package::Publisher                                                                                                 │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: DtnSanLCviUjU4fAK8sbbRaGQRBrehkziutvshSkVo1W                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xecff183718c1ac01ee2569171431f66eebd916a2cbcad2e1dec578270153579b                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0x2::display::Display<0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::nft_token::IsekaiBlade>       │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: 7TuZ3dWqQEpN6V8gmcj6o9fwbpy5JRmuHs1cJVoogiG9                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xf76fdc5a912c3e4f9774a7d99097d55940a3c34477d121a9d8efe97417d5be47                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::isekai_blade::AdminCap                              │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: 2beQCrc8P19meRKyP2BAfFasdcgkyjA9x5vfApanNBhC                                                                                │
│  └──                                                                                                                                   │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0xfe1b487e7f7f18e213d41f11201cf8a1ae1093aafa36b2d9c2a40e427d3d9083                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Shared( 563458048 )                                                                                                          │
│  │ ObjectType: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e::game_deposit::GameTreasury                          │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: CVSxxCvDtUg8hpzwS4nphxTNJhbiDKN8j3eKZLSxZ6Uq                                                                                │
│  └──                                                                                                                                   │
│ Mutated Objects:                                                                                                                       │
│  ┌──                                                                                                                                   │
│  │ ObjectID: 0x45b68b707eeb7e79fccc42315a3a75792eac9de617377d0b624c7741beeae268                                                        │
│  │ Sender: 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39                                                          │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )                                       │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                          │
│  │ Version: 563458048                                                                                                                  │
│  │ Digest: Pv8mP6QzHF1mnyZNr2fMzhPr6rLU6UzWcuggFTGHbWH                                                                                 │
│  └──                                                                                                                                   │
│ Published Objects:                                                                                                                     │
│  ┌──                                                                                                                                   │
│  │ PackageID: 0xef2bb0f0a68f9a92567baea63ea0e9d09334ce82a80a9a1161dbc4c047d0fe9e                                                       │
│  │ Version: 1                                                                                                                          │
│  │ Digest: 58LuztGYHhKoXW2LYFjm6GmpKWUSS5SRCYGHSn3LNGhY                                                                                │
│  │ Modules: access_control, attributes_chain, collection, game_deposit, image_generator, isekai_blade, marketplace, nft_token, upgrade │
│  └──                                                                                                                                   │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                              │
│  │ Owner: Account Address ( 0x97862ddea62d256c69c05f32b9c512ef935aa56546912bfc1665f4817d752e39 )  │
│  │ CoinType: 0x2::sui::SUI                                                                        │
│  │ Amount: -377230680                                                                             │
│  └──                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯

Process finished with exit code 0


