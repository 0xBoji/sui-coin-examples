// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Example coin with a trusted owner responsible for minting/burning (e.g., a stablecoin)
module coin_example::my_coin {
    use std::option;

    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const COIN_DECIMALS: u8 = 9; // The number of decimal places for the coin

    // The coin type. Must be the uppercase of the module name.
    struct MY_COIN has drop {}

    /// Register the trusted currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(otw: MY_COIN, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<MY_COIN>(
            otw,
            COIN_DECIMALS,
            b"MY_COIN",
            b"My coin name",
            b"My coin description",
            option::none(),
            ctx
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
    }

    #[lint_allow(self_transfer)]
    public entry fun mint(treasury_cap: &mut TreasuryCap<MY_COIN>, amount: u64, ctx: &mut TxContext) {
        let coin = coin::mint<MY_COIN>(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, tx_context::sender(ctx));
    }

    #[lint_allow(self_transfer)]
    public entry fun split_and_self_transfer(coin: &mut Coin<MY_COIN>, split_amount: u64, ctx: &mut TxContext) {
        let coin_s = coin::split(coin, split_amount, ctx);
        transfer::public_transfer(coin_s, tx_context::sender(ctx));
    }

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(MY_COIN {}, ctx)
    }
}
