// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Factory.sol";
import "./MockUniswapV2Pair.sol";

contract MockUniswapV2Factory is IUniswapV2Factory {
    // Can create only one pair
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        return address(new MockUniswapV2Pair(tokenA, tokenB));
    }
}
