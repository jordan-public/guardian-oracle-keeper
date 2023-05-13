// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./IGuarded.sol";
import "./IGuardianToken.sol";

interface IGuardian {
    function setAuthorizedPool(address pool) external;
    function getTokenPair() external view returns (IGuardianToken tokenA, IGuardianToken tokenB);
    function getUnderlyingTokenPair() external view returns (IERC20 tokenA, IERC20 tokenB);
    function getPrice() external view returns (uint256);
    function registerCallback(IGuarded guarded, uint256 priceTarget, bool descend) external payable;
    function transferAction(address sender, address recipient) external;
}