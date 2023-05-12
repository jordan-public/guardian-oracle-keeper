// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IGuarded.sol";

interface IGuardian {
    function wrap(uint256 amount) external;
    function unwrap(uint256 amount) external;
    function registerCallback(IGuarded guarded) external;
}