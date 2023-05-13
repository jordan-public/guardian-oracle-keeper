// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./IGuarded.sol";
import "./IGuardianToken.sol";

interface IGuardian {
    function getTokenPair() external view returns (IGuardianToken tokenA, IGuardianToken tokenB);
    function getUnderlyingTokenPair() external view returns (IERC20 tokenA, IERC20 tokenB);
    function registerCallback(IGuarded guarded) external;
    function transferAction(address sender, address recipient) external;
}