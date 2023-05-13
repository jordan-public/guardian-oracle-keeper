// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IGuarded.sol";
import "./Guardian.sol";

contract AaveLiquidator is IGuarded {
    uint256 lastPrice; // = 0
    IGuardian guardian;
    uint256 public priceActionCount; // = 0;

    event PriceChanged(uint256 oldPrice, uint256 newPrice);

    constructor (IGuardian g) {
        guardian = g;
    }

    function registerCallback(uint256 priceThreshold, bool descend, uint256 reward) external {
        guardian.registerCallback{value: reward}(this, priceThreshold, descend);
    }

    function priceAction(uint256 balanceA, uint256 balanceB) external {
        (IERC20 tokenA, IERC20 tokenB) = guardian.getUnderlyingTokenPair();
        uint256 newPrice = ((((balanceB * 10**tokenA.decimals()) / balanceA)  * 1 ether) / 10**tokenB.decimals()); // 18 decimals
        emit PriceChanged(lastPrice, newPrice);
        lastPrice = newPrice;
    }
}
