// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
import "./IGuardian.sol";

interface IGuardianFactory {
    function createGuardian(IERC20 tokenA, IERC20 tokenB, address authorizedPool) external returns (IGuardian);
}