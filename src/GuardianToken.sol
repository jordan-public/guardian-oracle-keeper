// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
import "./interfaces/IGuarded.sol";
import "./interfaces/IGuardian.sol";

contract GuardianToken is IERC20, IGuardian {
    IERC20 underlyingToken;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply; // = 0

    mapping (address => bool) isAuthorizedPool;
    IGuarded[] public toGuard;

    constructor (IERC20 toWrap, address[] memory authorizedPools) {
        underlyingToken = toWrap;
        name = "g";
        symbol = "Guardian";
        name = string(abi.encodePacked(name,toWrap.name()));
        symbol = string(abi.encodePacked(symbol," ",toWrap.symbol()));
        decimals = toWrap.decimals();
        // no need totalSupply = 0;
        for (uint256 i = 0; i < authorizedPools.length; i++)
            isAuthorizedPool[authorizedPools[i]] = true;
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

    function registerCallback(IGuarded guarded) external {
        toGuard.push(guarded);
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
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient funds");
        require(allowance[sender][msg.sender] >= amount, "Unauthorized");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
} 