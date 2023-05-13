// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IGuarded.sol";
import "./Guardian.sol";
import "./mock/MockLendingPool.sol";

contract AaveLiquidator is IGuarded {
    uint256 lastPrice; // = 0
    IGuardian guardian;
    uint256 public priceActionCount; // = 0;
    ILendingPool lendingPool;

    event PriceChanged(uint256 oldPrice, uint256 newPrice);

    constructor (IGuardian g) {
        guardian = g;
        lendingPool = new MockLendingPool();
    }

    receive() external payable {} // Can get ETH for reward payments

    function calculateLiquidationPrice() internal view returns (uint256) {
        (uint256 totalCollateralETH, uint256 totalDebtETH, , uint256 currentLiquidationThreshold, , ) = lendingPool.getUserAccountData(tx.origin);
        
        // Get current price of the collateral
        uint256 currentCollateralPrice = guardian.getPrice(); // Pricing 1 billion PEPE
        
        // Calculate the liquidation price
        uint256 liquidationPrice = totalDebtETH * currentLiquidationThreshold / (totalCollateralETH * currentCollateralPrice);

        return liquidationPrice;
    }

    function registerCallback(uint256 reward) external {
        guardian.registerCallback{value: reward}(this, calculateLiquidationPrice(), true); // On descending price below liquidation level
    }

    function priceAction(uint256, uint256) external {
        (IERC20 PEPE, IERC20 GHO) = guardian.getUnderlyingTokenPair();
        lendingPool.liquidationCall(address(PEPE), address(GHO), tx.origin, type(uint256).max, false);
        priceActionCount += 1;
    }
}
