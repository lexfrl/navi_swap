module navi_swap::flash_swap_module {
    use cetus_clmm::pool::{Pool as AMMPool};
    use cetus_clmm::pool;
    use cetus_clmm::pool::FlashSwapReceipt;
    use cetus_clmm::config::GlobalConfig;
    use sui::clock::Clock;
    use sui::balance;
    use sui::balance::Balance;
    use lending_core::pool::Pool;
    use lending_core::storage::{Storage};
    use oracle::oracle::{PriceOracle};
    use sui::balance::destroy_zero;
    use lending_core::incentive_v2::{Incentive, repay, borrow};

    const SQRT_PRICE_LIMIT_A2B: u128 = 4295048016;
    const SQRT_PRICE_LIMIT_B2A: u128 = 79226673515401279992447579055;

    entry public fun do_swap<CoinTypeA, CoinTypeB>(
        amount: u64,
        a2b: bool,
        amount_in: bool,
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
        let sqrt_price_limit = if (a2b) { SQRT_PRICE_LIMIT_A2B } else { SQRT_PRICE_LIMIT_B2A };
        let (receive_a, receive_b, flash_receipt) = pool::flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            a2b,
            amount_in,
            amount,
            sqrt_price_limit,
            clock
        );
        if (a2b) {
            let b_value = receive_b.value();
            let new_b = repay(clock, oracle, storage, pool_b, pool_asset_id_b, receive_b.into_coin(ctx), b_value, incentive, ctx);
            let new_borrow = borrow(clock, oracle, storage, pool_a, pool_asset_id_a, pool::swap_pay_amount(&flash_receipt), incentive, ctx);
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
        } else {
            let a_value = receive_a.value();
            let new_a = repay(clock, oracle, storage, pool_a, pool_asset_id_a, receive_a.into_coin(ctx), a_value, incentive, ctx);
            let new_borrow = borrow(clock, oracle, storage, pool_b, pool_asset_id_b, pool::swap_pay_amount(&flash_receipt), incentive, ctx);
            new_a.destroy_zero();
            receive_b.destroy_zero();
            let (pay_coin_a, pay_coin_b) = (balance::zero(), new_borrow);
            pool::repay_flash_swap<CoinTypeA, CoinTypeB>(
                config,
                pool,
                pay_coin_a,
                pay_coin_b,
                flash_receipt
            );
        }
    }
}
