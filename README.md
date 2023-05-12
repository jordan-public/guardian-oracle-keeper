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

Our protocol creates a pair of Guardian Oracle-Keeper Tokens called gWETH and gUSDC, each wrapping WETH (wrapped 1-to-1 ETH) and USDC respectively. Note that these new tokens are Friends, effectively aware of each other. Each one of them is tracking its total supply. Upon each transfer, the ratio of the total supplies is calculated, which determines their relative price. 

Outside protocols can subscribe to one-time function callbacks for a fee. If the callback function would be responsible for re-subscribing again, which makes the process simple and flexible.

When the price changes, the tokens go through the list of subscriptions and call the relevant callbacks with the price as parameter. More on the efficient data structures for this below. 

Now this pair of Guardian Oracle-Keeper Tokens can be deployed as liquidity on any DEX. As traders trade these tokens, they call the callbacks and perform liquidations on various protocols.
## Safety

The pair of Guardian Oracle-Keeper Tokens can be abused in order to manipulate their relative prices. In order to prevent this, the Guardian Oracle-Keeper Tokens have a list of authorized owners, set upon their creation. This list includes specific DEXes (actually LP pairs on those DEXes). Any other owner can only mint these tokens in the exact proportion as the current price. The process goes as follows:

- The Guardian Oracle-Keeper Token pair is created with a list of authorized owners (usually one LP at a DEX such as Unsiwap V3, V2, Sushiswap, etc.).

- The depositors authorize the transfer of the underlying tokens for each wrapped Guardian Oracle-Keeper Token. For example, the depositor authorizes the gWETH contract to transfer WETH and gUSDC to transfer USDC on their behalf.

- The depositor consequently calls the "mint" function on one of the Friend Guardian Oracle-Keeper Tokens, which transfers in and wraps both tokens in the amounts proportional to the current price.

- Then such pair can be deposited on the authorized DEX as LP.

- When a swap is performed, the destination tokens are immediately burned.
## Economic Incentive

## Optimal Data Structures

## Use Cases

Infinity protocol