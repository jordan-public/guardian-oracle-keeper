# The Guardian Oracle-Keeper Token

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

What if we create special tokens? Somehow, when it's price changes on the existing DEXes it would call a registered callback function to perform liquidations or similar business. Enter the Guardian Oracle-Keeper Tokens:

## Guardian Oracle-Keeper Token Protocol

The Guardian Oracle-Keeper Tokens are ERC-20 tokens issued in pairs which we call Friends. They wrap existing ERC-20 tokens and provide additional functionality. 

For example, we have a protocol in need of liquidations based on the ETH/USDC pricing. The function "liquidate(uint256 price)" has to be called when the price crosses the specified value. 

Our protocol creates a pair of Guardian Oracle-Keeper Tokens called gWETH and gUSDC, each wrapping WETH (wrapped 1-to-1 ETH) and USDC respectively. Note that these new tokens are Friends, effectively aware of each other. Each one of them is tracking its total supply (well, the supply owned bu authorized DEXes to be precise as this is discussed below in the Safety section). Upon each transfer, the ratio of the total supplies is calculated, which determines their relative price. 

Outside protocols can subscribe to one-time function callbacks for a fee. If the callback function would be responsible for re-subscribing again, which makes the process simple and flexible.

When the price changes, the tokens go through the list of subscriptions and call the relevant callbacks with the price as parameter. More on the efficient data structures for this below. 

Now this pair of Guardian Oracle-Keeper Tokens can be deployed as liquidity on any DEX. As traders trade these tokens, they call the callbacks and perform liquidations on various protocols.
## Safety

The pair of Guardian Oracle-Keeper Tokens can be abused in order to manipulate their relative prices. In order to prevent this, the Guardian Oracle-Keeper Tokens have a list of authorized DEXes, set upon their creation. This list includes specific DEXes (actually LP pair contracts on those DEXes). Importantly, **only the tokens owned by these autorized DEXes count towards the ratio that determines the price**. The process goes as follows:

- The Guardian Oracle-Keeper Token pair is created with a list of authorized owners (usually one LP at a DEX such as Unsiwap V3, V2, Sushiswap, etc.).

- The depositors authorize the transfer of the underlying tokens for the desired wrapped Guardian Oracle-Keeper Token. For example, the depositor authorizes the gUSDC contract to transfer USDC on his behalf, and calls the "wrap" function which mints and equal amount of gUSDC tokens owned by the depositor.

- Then such pair can be deposited on (any, but relevantly) the authorized DEX as LP.

- The user which swaps one token can unwrap the received token from the DEX, in addition to receiving share of the rewards for performing callback services.

Let us consider another issue: low gWETH/gUSDC liquidity on the authorized DEX. This is not a problem in itself, as it represents a great flash loan opportunity for price arbitrage between gWETH/gUSDC and WETH/USDC. A simple flash swap from Uniswap V3 to any authorized DEX would provide firm pricing on gWETH/gUSDC with almost the same quality as WETH/USDC on Uniswap V3.

## Economic Incentive

Why would anyone provide gWETH/gUSDC liquidity and why would anyone swap or hold these tokens at all, instead of just WETH and USDC? The answer is: for economic incentive.

Each time Guardian Oracle-Keeper Tokens change hands through an authorized DEX, they potentially cross registered callback price thresholds. Consequently, those callbacks are called and fees are collected for this service. The fees accrue inside the DEX LP contracts, increasing their value. When the LP withdraws his liquidity, part of the profit from this operation is built in it.

The incentive for the traders on the authorized DEX is also distributed from part of the callback service operation. Each time a callback is executed, the involved DEX trader immediately receives his reward.
## Optimal Data Structures

Note: Initially this protocol implements the list of callbacks as a regular Solidity array (to complete the work in 1.5 days for the hackathon).

The data structure for holding the list of registered callbacks is implemented as a doubly-linked list sorted by price. A marker is placed pointing to the first item with trigger price at or below the pointed record. As the price moves due to activity on the authorized DEX, the marker is moved towards the new price, sweeping, executing and removing all callbacks in the list up to the new price. This is efficient, as rewards are collected for each callback execution.
## Use Cases

The Guardian Oracle-Keeper Tokens can have wide usage in DeFi. They solve a crucial problem of dangerous liquidation latency, which many protocols suffer from.

New generation DeFi protocols try to alleviate this problem at other **adverse risks and costs**. For examnple the [Infinity Pools](https://infpools.medium.com/introducing-infinitypools-or-how-i-learned-to-stop-worrying-and-love-leverage-9b44fc8367b6) provide spot trading wih arbitrary leverage (marketed as infinite although limited by cost) by lending concentrated liquidity to the traders, for example a long leverage spot trader can borrow liquidity concentrated below the current price (the closer to the price, the greater the leverage). When the value of the long leveraged position falls below the limit, the borrowed concentrated LP position transforms itself covering for the loss. However, at what cost? The liquidity investor in this protocol is stuck holding an out-of-range concentrated LP position (not generating revenue), with potential not-so-impermanent loss. This consequently makes it costly for the trader. Not to mention the trader holding short LP, a very dangerous liability if that super concentrated liquidity starts producing profit for the lender, out of control for the trader in addition to his liquidation troubles.

## Example use case: improve/fix the Infinity Pools Protocol

Here is how an improved Infinity Pools protocol can work:

- The trader wants to enter a position, for example, 10x leverage long WETH/USDC.

- The liquidation price is set to slightly less than 10% below the current price (less than 10% in order to accommodate for liquidation penalty). A liquidation callback is registered with the gWETH/gUSDC Friend Guardian Oracle-Keeper Tokens with the above liquidation price as threshold. 

- The protocol performs instant liquidation with no risk. Some slippage provision has to be accounted for in the liquidation penalty, of course. 

The above fix removes the need for holding the dangerous concentrated liquidity positions for the liquidity provider, and also holding short LP for the trader and the extra cost.