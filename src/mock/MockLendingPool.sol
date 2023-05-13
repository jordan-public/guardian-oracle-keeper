// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/ILendingPool.sol";

contract MockLendingPool is ILendingPool {
    uint256 bs; // To match mutability with the real LendingPool

    function getUserAccountData(address) external view returns (
        uint256 totalCollateralETH,
        uint256 totalDebtETH,
        uint256 availableBorrowsETH,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    ) {
        totalCollateralETH = 2 * 10e18;
        totalDebtETH = 10e18;
        availableBorrowsETH = bs; // Irrelevant to our calculation - make function view instead of pure
        currentLiquidationThreshold = 15 * 10e17;
        ltv = 5 * 10e17; // Irrelevant to our calculation
        healthFactor = 10e18; // Irrelevant to our calculation
    }

    function liquidationCall(
        address,
        address,
        address,
        uint256,
        bool
    ) external {
        // In reality, this call liquidates the borrower's position
        console.log("*** Aave liquidation triggered! ***");
        bs += 1;
    }
}
