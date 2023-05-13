// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ILendingPool {
    function getUserAccountData(address user) external view returns (
        uint256 totalCollateralETH,
        uint256 totalDebtETH,
        uint256 availableBorrowsETH,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    );

    function liquidationCall(
        address collateral,
        address debt,
        address user,
        uint256 debtToCover,
        bool useReceiveAToken
    ) external;
}
