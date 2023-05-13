// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
import "./Guardian.sol";
import "./interfaces/IGuardianFactory.sol";

contract GuardianFactory is IGuardianFactory {
    function createGuardian(IERC20 tokenA, IERC20 tokenB, address authorizedPool) external returns (IGuardian) {
        return new Guardian(tokenA, tokenB, authorizedPool);
    }
}