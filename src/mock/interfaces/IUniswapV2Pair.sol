// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IUniswapV2Pair {
    function mint(address to) external returns (uint256 liquidity);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}