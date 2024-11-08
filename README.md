# Rationale

As a DeFi user, I often encounter situations where I want to switch (or exchange) assets that I'm borrowing or using as collateral in a lending protocol such as [Navi](https://app.naviprotocol.io/borrow). For example, if I want to switch a loan from USDT to USDC, I first need to repay the USDT debt before I can borrow USDC. However, sometimes I don't have enough USDT on hand to cover the debt first, leaving me stuck.

# Solution

The solution is to leverage [flash_swap](https://cetus-1.gitbook.io/cetus-developer-docs/developer/via-contract/features-available/swap-and-preswap), which splits the swap process into two steps: `flash_swap` and `repay_flash_swap`. In the `flash_swap` operation, you initiate a swap from asset A to asset B, with the promise to return the equivalent of asset B in the `repay_flash_swap` step. This allows you to obtain asset A to repay the debt, and then borrow asset B to complete the repayment of the flash swap.

# Next Steps

The next logical step is to implement the same mechanism for the collateral side. There are also several additional ideas to explore for rebalancing portfolios and optimizing asset management.

I'm considering to write a post to describe my overall experience of interacting with Sui (which is quite positive!) next week!

[Demo video](https://www.youtube.com/watch?v=1CLQv-YQ8q4)

Live on https://navi-cetus-swap.vercel.app (mainnet)

Appreciate your feedback (I'm testing with my own funds on the mainnet, but consider it's an alfa software)!
