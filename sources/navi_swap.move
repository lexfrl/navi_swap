module navi_swap::flash_swap_module {
    use cetus_clmm::pool::{Pool as AMMPool};
    use cetus_clmm::pool;
    use cetus_clmm::config::GlobalConfig;
    use sui::clock::Clock;
    use sui::coin;
    use sui::balance;

    use lending_core::pool::Pool;
    use lending_core::storage::{Storage};
    use oracle::oracle::{PriceOracle};
    use sui::balance::destroy_zero;
    use sui::coin::{Coin, from_balance};
    use sui::{transfer::public_transfer, tx_context};
    // use sui::coin::{Self, Coin};
    use lending_core::lending::{flash_loan_with_ctx, flash_repay_with_ctx};
    use lending_core::incentive::{Incentive as IncentiveV1};
    use lending_core::incentive_v2::{Incentive, repay, borrow};

    const SQRT_PRICE_LIMIT_A2B: u128 = 4295048016;
    const SQRT_PRICE_LIMIT_B2A: u128 = 79226673515401279992447579055;

    entry public fun do_swap<CoinTypeA, CoinTypeB>(
        amount: u64,
        pool_asset_id_a: u8, 
        pool_asset_id_b: u8,
        pool_a: &mut Pool<CoinTypeA>,
        pool_b: &mut Pool<CoinTypeB>,
        storage: &mut Storage,
        incentive: &mut Incentive,
        oracle: &PriceOracle,
        pool:  &mut AMMPool<CoinTypeA, CoinTypeB>,
        config: &GlobalConfig,
        clock: &Clock,
        ctx: &mut TxContext
        ) {
        let (receive_a, receive_b, flash_receipt) = pool::flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            true,
            true,
            amount,
            SQRT_PRICE_LIMIT_A2B,
            clock
        );
        let (in_amount, out_amount) = (pool::swap_pay_amount(&flash_receipt), balance::value(&receive_b));
        let b_value = receive_b.value();
        let new_b = repay(clock, oracle, storage, pool_b, pool_asset_id_b, receive_b.into_coin(ctx), b_value, incentive, ctx);
        let new_borrow = borrow(clock, oracle, storage, pool_a, pool_asset_id_a, amount, incentive, ctx);
        new_b.destroy_zero();
        receive_a.destroy_zero();
        let (pay_coin_a, pay_coin_b) = (new_borrow, balance::zero());
        pool::repay_flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            pay_coin_a,
            pay_coin_b,
            flash_receipt
        );
    }
}
