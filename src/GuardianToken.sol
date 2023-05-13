// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
import "./interfaces/IGuarded.sol";
import "./interfaces/IGuardian.sol";
import "./interfaces/IGuardianToken.sol";

contract GuardianToken is IGuardianToken {
    IERC20 public underlyingToken;
    IGuardian public coordinator;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply; // = 0

    constructor (IERC20 toWrap) {
        underlyingToken = toWrap;
        name = "g";
        symbol = "Guardian";
        name = string(abi.encodePacked(name,toWrap.name()));
        symbol = string(abi.encodePacked(symbol," ",toWrap.symbol()));
        decimals = toWrap.decimals();
        // no need totalSupply = 0;
        coordinator = IGuardian(msg.sender);
    }

    function wrap(uint256 amount) external {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        balanceOf[msg.sender] += amount;
    }

    function unwrap(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        underlyingToken.transfer(msg.sender, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient funds");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        coordinator.transferAction(msg.sender, recipient);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient funds");
        require(allowance[sender][msg.sender] >= amount, "Unauthorized");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        coordinator.transferAction(sender, recipient);
        emit Transfer(sender, recipient, amount);
        return true;
    }
} 