// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IGuarded {
    function priceAction(uint256 balanceA, uint256 balanceB) external;
}