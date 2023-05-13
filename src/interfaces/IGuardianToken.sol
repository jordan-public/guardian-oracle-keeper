// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";

interface IGuardianToken is IERC20 {
    function wrap(uint256 amount) external;
    function unwrap(uint256 amount) external;
    function underlyingToken() external view returns (IERC20);
}