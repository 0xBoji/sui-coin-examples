module coin_example::my_coin_faucet {
    use sui::balance;
    use sui::balance::Balance;
    use sui::coin;
    use sui::coin::Coin;
    use sui::object;
    use sui::object::UID;
    use sui::transfer;
    use sui::transfer::public_transfer;
    use sui::tx_context::{sender, TxContext};

    use coin_example::my_coin::MY_COIN;

    const EInsufficientRepayment: u64 = 1;

    const A_DROP_AMOUNT: u64 = 100_000_000_000;

    /// a "hot-potato"
    struct LoanReceipt {
        amount: u64,
    }

    struct MyCoinFaucet has key, store {
        id: UID,
        balance: Balance<MY_COIN>,
    }

    public entry fun create_faucet(coin: &mut Coin<MY_COIN>, amount: u64, ctx: &mut TxContext) {
        let faucet = MyCoinFaucet {
            id: object::new(ctx),
            balance: coin::into_balance(coin::split(coin, amount, ctx)),
        };
        transfer::share_object(faucet)
    }

    public entry fun request_a_drop(faucet: &mut MyCoinFaucet, ctx: &mut TxContext) {
        let b = balance::split(&mut faucet.balance, A_DROP_AMOUNT);
        public_transfer(coin::from_balance(b, ctx), sender(ctx))
    }

    /// Replenish
    public entry fun replenish_faucet(
        faucet: &mut MyCoinFaucet,
        coin: &mut Coin<MY_COIN>,
        amount: u64,
        ctx: &mut TxContext
    ) {
        balance::join(&mut faucet.balance, coin::into_balance(coin::split(coin, amount, ctx)));
    }

    /// Borrow a loan.
    public fun borrow_loan(
        faucet: &mut MyCoinFaucet,
        amount: u64,
        _ctx: &mut TxContext
    ): (Balance<MY_COIN>, LoanReceipt) {
        let loan = balance::split(&mut faucet.balance, amount);
        let amount = balance::value(&loan);
        (loan, LoanReceipt { amount })
    }

    /// Repay the loan.
    public fun repay_loan(
        faucet: &mut MyCoinFaucet,
        repayment: Balance<MY_COIN>,
        receipt: LoanReceipt,
        _ctx: &mut TxContext
    ) {
        let loan_amount = receipt.amount;
        assert!(loan_amount <= balance::value(&repayment), EInsufficientRepayment);
        balance::join(&mut faucet.balance, repayment);
        let LoanReceipt {
            amount: _
        } = receipt;
    }

    #[test]
    public entry fun borrow_arbitrage_repay_template_(faucet: &mut MyCoinFaucet, ctx: &mut TxContext) {
        let borrow_amount = 100_000_000_000_000;
        let (loan, receipt) = borrow_loan(faucet, borrow_amount, ctx);

        //
        // TODO arbitrage...
        let b = loan; // <- This is a placeholder for the arbitrage logic.
        //

        let repayment = balance::split(&mut b, borrow_amount);
        let profit = coin::zero<MY_COIN>(ctx);
        coin::join(&mut profit, coin::from_balance(b, ctx));
        public_transfer(profit, sender(ctx));

        repay_loan(faucet, repayment, receipt, ctx);
    }
}
