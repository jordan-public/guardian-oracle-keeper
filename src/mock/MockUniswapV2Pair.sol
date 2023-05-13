// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract MockUniswapV2Pair is IUniswapV2Pair {
    address token0;
    address token1;
    uint256 bs;

    constructor (address t0, address t1) {
        token0 = t0;
        token1 = t1;
    }

    function mint(address) external returns (uint256) {
        bs += 1; // Just to silence the warnings without a directive
        return 1; // Just gobble up the funds - will never refund
    }

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata) external {
        // It just blindly accepts any request withour the constant product restriction
        IERC20(token0).transfer(to, amount0Out);
        IERC20(token1).transfer(to, amount1Out);
    }
}