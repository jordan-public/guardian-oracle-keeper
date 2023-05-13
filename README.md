# The Guardian Oracle-Keeper Protocol

## Abstract

I developed a novel on-chain Keeper protocol which reacts upon price actions immediately, within the same transaction. 

DeFi protocols have suffered issues from latent Oracles and slow reaction by the Liquidation Keepers. **No more!** This protocol allows DeFi protocols to immediately react to price actions, as soon as they occur on-chain.

The protocol mechanism is implemented as a pair of Guardian Tokens which can wrap any pair of ERC20 tokens and deploy them at one or more Automated Market Maker DEXes. These tokens intercept the "transfer" functions and reverse-calculate the price as soon as transactions occur, and immediately call registered callbacks. These callbacks are typically liquidation or rebalancing operations performed by the DeFi protocols utilizing the Guardian Oracle-Keeper Protocol.


## Intruduction

Many DeFi protocols depend on Oracles, Keepers and Liquidators. 

- Oracles provide data external to the protocols. External oracles, such as ChainLink reliably in a decentralized manner bring off-chain data and record it on-chain. However, on-chain oracles exist, too. For example Uniswap can be used as on-chain oracle. It even provides for recording a trail of prices to avoid flash loan or flash swap attacks. 

- Keepers watch for certain off-chain or on-chain events and call on-chain contracts to perform an action triggered by such events. 

- Liquidators make sure all DeFi participants are solvent and can deliver on their financial commitments to their counter-parties. Participants approaching insolvency according to prescribed rules should be liquidated by Liquidators, parties that are able to remedy their insolvency, typically by taking over their positions in exchange for reward charged as penalty to the liquidated participant.

## Problems

All above seems in order, but there are numerous problems:

- Keepers may not react timely. This could cause insolvent positions to damage the protocol beyond repair, at the cost of the honest participants.

- Liquidators triggered by Keepers may introduce additional risk, as they may reluctantly decide not to liquidate certain positions, in favor of others in order to maximize their own rewards.

- Off-chain oracles can lag. Especially in high congestion situations, cost can cause the off-chain oracles to delay their delivery. In addition, off-chain oracles are not instant. 

- On-chain oracles are instant as they reflect current trading, but they still need external keepers to trigger liquidations, so this becomes a moot point.

## What if?

What if the Decentralized Exchanges (DEX) can deliver callbacks based on trading events? That would be nice, but they don't. We can build a DEX which does, but who would use our new DEX? If there is no liquidity on it, it would be unreliable, and we are back to the marketing and market share problem. 

What if we create special tokens? Somehow, when it's price changes on the existing DEXes it would call a registered callback function to perform liquidations or similar business. Enter the Guardian Tokens:

## Guardian Oracle-Keeper Protocol

The Guardian Oracle-Keeper Protocol is implemented as a pair of Guardian Tokens.

The Guardian Tokens are ERC20 tokens issued in pairs which we call Friends. They wrap existing ERC20 tokens and provide additional functionality. In a way, they are indistinguishable to the liquidity pool from any other tokens, thus acting as Trojan Horses.

For example, we have a protocol in need of liquidations based on the ETH/USDC pricing. The function "liquidate(uint256 price)" has to be called when the price crosses the specified value. 

Our protocol creates a pair of Guardian Tokens called gWETH and gUSDC, each wrapping WETH (wrapped 1-to-1 ETH) and USDC respectively. Note that these new tokens are Friends, effectively aware of each other. Each one of them is tracking its total supply (well, the supply owned bu authorized DEXes to be precise as this is discussed below in the Safety section). Upon each transfer, the ratio of the total supplies is calculated, which determines their relative price. 

Outside protocols can subscribe to one-time function callbacks for a fee. If the callback function would be responsible for re-subscribing again, which makes the process simple and flexible.

When the price changes, the tokens go through the list of subscriptions and call the relevant callbacks with the price as parameter. More on the efficient data structures for this below. 

Now this pair of Guardian Tokens can be deployed as liquidity on any DEX. As traders trade these tokens, they call the callbacks and perform liquidations on various protocols.
## Safety

The pair of Guardian Tokens can be abused in order to manipulate their relative prices. In order to prevent this, the Guardian Tokens have a list of authorized DEXes, set upon their creation. This list includes specific DEXes (actually LP pair contracts on those DEXes). Importantly, **only the tokens owned by these autorized DEXes count towards the ratio that determines the price**. The process goes as follows:

- The Guardian Token pair is created with a list of authorized owners (usually one LP at a DEX such as Unsiwap V3, V2, Sushiswap, etc.).

- The depositors authorize the transfer of the underlying tokens for the desired wrapped Guardian Token. For example, the depositor authorizes the gUSDC contract to transfer USDC on his behalf, and calls the "wrap" function which mints and equal amount of gUSDC tokens owned by the depositor.

- Then such pair can be deposited on (any, but relevantly) the authorized DEX as LP.

- The user which swaps one token can unwrap the received token from the DEX, in addition to receiving share of the rewards for performing callback services.

Let us consider another issue: low gWETH/gUSDC liquidity on the authorized DEX. This is not a problem in itself, as it represents a great flash loan opportunity for price arbitrage between gWETH/gUSDC and WETH/USDC. A simple flash swap from Uniswap V3 to any authorized DEX would provide firm pricing on gWETH/gUSDC with almost the same quality as WETH/USDC on Uniswap V3.

## Price Calculation

Once a transfer in or out of an authorized DEX pool is detected (this is simply part of the "transfer" and "transferFrom" functions of the ERC20 tokens), the new price has to be calculated. There are several choices, and here is the summary:

### Latest Price Calculation - AMM Liquidity Pool Reverse Engineering

If the authorized pool is a full-range liquidity pool, such as Uniswap V2 or any of its clones such as SushiSwap, there only needs to be a single pool in the authorized list, as the pool is always active. In such case the latest price is simply the ratio of the Friend Guardian Tokens in the pool, for example:

$ p(gWETH, gUSDC) = q(gUSDC) /q(gWETH)$

$p(A, B)$ is the price of token $A$ expressed in token $B$ and $q(Token)$ is the amount of that token in the pool. 

NOTE: For the hackathon demo we will be calculating prices assuming the tokens are deposited in a single Uniswap V2 pool. However, this is not a limitation.

If the Friend Guardian Tokens are deposited in a concentrated liquidity pool, the price can also be calculated. Note that calculating the current price for Uniswap V3 is not a simple task, as all pools for the desired token pair have to be consulted. Uniswap V3 has an off-chain library for this (```@uniswap/sdk```), but no on-chain solution, as it would require iterating through all pools for that pair, which would be too expensive. **Luckily**, the reverse engineering is simpler: we know which pool has been triggered, as we keep the list of authorized pools (actually this is a map; see the Optimal Data Structures section below). Then, the price in the concentrated liquidity pool in question can be calculated as follows:

$p(gWETH, gUSDC) = \sqrt{L * U} * \sqrt{q(gUSDC) /q(gWETH)}$

where $p$ and $q$ is the same as above and $L$ and $U$ are the lower and upper bounds of the concentrated liquidity tick boundary (Note: I need reference here; I derived this from common sense). 

### Price Averaging

Following the same lucky circumstance as above, Guardian Token knows who called its "transfer" or "transferFrom" function, so even if the pool is Uniswap V3 concentrated liquidity, the Uniswap V3 built-in "oracle" can be called for price averaging during the last second:

```
function getUniV3Price(uint32 secondsAgo) public view returns (int56) {
        uint32[] memory secondsAgos = new uint32[](1);
        secondsAgos[0] = secondsAgo;

        int56[] memory tickCumulatives = IUniswapV3Pool(uniswapV3PoolAddress).observe(secondsAgos);
        return tickCumulatives[0];
    }
```

Note that this is a responsibility of the consumer of the Guardian Token callback, so we are not going to go into details nor implement this. The above function merely shows that such calculation is not only possible but very feasible and inexpensive.
## Economic Incentive

Why would anyone provide gWETH/gUSDC liquidity and why would anyone swap or hold these tokens at all, instead of just WETH and USDC? The answer is: for economic incentive.

Each time Guardian Tokens change hands through an authorized DEX, they potentially cross registered callback price thresholds. Consequently, those callbacks are called and fees are collected for this service. The fees accrue inside the DEX LP contracts, increasing their value. When the LP withdraws his liquidity, part of the profit from this operation is built in it.

The incentive for the traders on the authorized DEX is also distributed from part of the callback service operation. Each time a callback is executed, the involved DEX trader optimistically receives his reward before even the Guardian callback is executed. This pays for the transaction (gas) fees and more, all in advance.
## Optimal Data Structures

Note: Initially this protocol implements the list of callbacks as a regular Solidity array (to complete the work in 1.5 days for the hackathon).

The data structure for holding the list of registered callbacks is implemented as a doubly-linked list sorted by price. A marker is placed pointing to the first item with trigger price at or below the pointed record. As the price moves due to activity on the authorized DEX, the marker is moved towards the new price, sweeping, executing and removing all callbacks in the list up to the new price. This is efficient, as rewards are collected for each callback execution.

In addition, the list of authorized DEX pools is implemented as Solidity map of pool addresses to Boolean. When a transfer is made, Guardian Token "transfer" and "transferFrom" check who performed the transfer (msg.sender is the address of the pool) and check in the map whether that address is an authorized DEX pool. If so, the price action is checked whether to trigger any of the callbacks in the doubly linked list above.
## Use Cases

The Guardian Tokens can have wide usage in DeFi. They solve a crucial problem of dangerous liquidation latency, which many protocols suffer from. Not limited to this, the usages would be:

- Liquidation in Lending (for exaple Aave).
- Liquidation in Leveraged Trading (for example DyDx).
- Rebalancing in yield farming (for example Yearn or Autofarm). Yes, rebalancing can be urgent, and this would allow farming on extremely volatile assets.

New generation DeFi protocols try to alleviate this problem at other **adverse risks and costs**. For examnple the [Infinity Pools](https://infpools.medium.com/introducing-infinitypools-or-how-i-learned-to-stop-worrying-and-love-leverage-9b44fc8367b6) provide spot trading wih arbitrary leverage (marketed as infinite although limited by cost) by lending concentrated liquidity to the traders, for example a long leverage spot trader can borrow liquidity concentrated below the current price (the closer to the price, the greater the leverage). When the value of the long leveraged position falls below the limit, the borrowed concentrated LP position transforms itself covering for the loss. However, at what cost? The liquidity investor in this protocol is stuck holding an out-of-range concentrated LP position (not generating revenue), with potential not-so-impermanent loss. This consequently makes it costly for the trader. Not to mention the trader holding short LP, a very dangerous liability if that super concentrated liquidity starts producing profit for the lender, out of control for the trader in addition to his liquidation troubles.

## Example use case: improve/fix the Infinity Pools Protocol

Here is how an improved Infinity Pools protocol can work:

- The trader wants to enter a position, for example, 10x leverage long WETH/USDC.

- The liquidation price is set to slightly less than 10% below the current price (less than 10% in order to accommodate for liquidation penalty). A liquidation callback is registered with the gWETH/gUSDC Friend Guardian Tokens with the above liquidation price as threshold. 

- The protocol performs instant liquidation with no risk. Some slippage provision has to be accounted for in the liquidation penalty, of course. 

The above fix removes the need for holding the dangerous concentrated liquidity positions for the liquidity provider, and also holding short LP for the trader and the extra cost.