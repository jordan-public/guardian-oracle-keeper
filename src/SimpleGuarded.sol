// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IGuarded.sol";
import "./Guardian.sol";

contract SampleGuarded is IGuarded {
    uint256 lastPrice; // = 0
    IGuardian guardian;

    event PriceChanged(uint256 oldPrice, uint256 newPrice);

    constructor (IGuardian g) {
        guardian = g;
    }

    function priceAction(uint256 balanceA, uint256 balanceB) external {
        (IERC20 tokenA, IERC20 tokenB) = guardian.getUnderlyingTokenPair();
        uint256 newPrice = ((((balanceB * 10**tokenA.decimals()) / balanceA)  * 1 ether) / 10**tokenB.decimals()); // 18 decimals
        emit PriceChanged(lastPrice, newPrice);
        lastPrice = newPrice;
    }
}
