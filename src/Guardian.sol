// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
import "forge-std/console.sol";
import "./interfaces/IGuarded.sol";
import "./interfaces/IGuardian.sol";
import "./GuardianToken.sol";

contract Guardian is IGuardian {
    address owner;
    address authorizedPool;
    bool isOdd; // = false
    struct TTarget {
        IGuarded toGuard;
        uint256 reward;
        uint256 priceTarget;
        bool descend;
    }
    TTarget[] public targets; // !!! This needs improvement - use doubly linked list instead of an array (to do after the hackathon)
    IGuardianToken gTokenA;
    IGuardianToken gTokenB;
    uint256 lastPrice; // = 0

    constructor (IERC20 tokenA, IERC20 tokenB) {
        owner = tx.origin; // Note: This breaks with ERC-4337. Deal with it later, by recording the owner of the creator!!!
        gTokenA = new GuardianToken(tokenA);
        gTokenB = new GuardianToken(tokenB);
    }

    function setAuthorizedPool(address pool) external {
        require(tx.origin == owner, "Unauthorized"); // Note: This breaks with ERC-4337. Deal with it later, by recording the owner of the creator!!!
        authorizedPool = pool;
    }

    function getTokenPair() external view returns (IGuardianToken tokenA, IGuardianToken tokenB) {
        return (gTokenA, gTokenB);
    }

    function getUnderlyingTokenPair() external view returns (IERC20 tokenA, IERC20 tokenB) {
        return (gTokenA.underlyingToken(), gTokenB.underlyingToken());
    }

    function registerCallback(IGuarded guarded, uint256 priceTarget, bool descend) external payable {
        lastPrice = getPrice();
        targets.push(TTarget(guarded, msg.value, priceTarget, descend));
    }

    // Return value always in 18 decimals
    function getPrice() public view returns (uint256 price) {
        if (gTokenB.balanceOf(authorizedPool) == 0) price = 0;
        else price = (1 ether * gTokenA.balanceOf(authorizedPool) * 10**gTokenB.decimals()) / (gTokenB.balanceOf(authorizedPool) * 10**gTokenA.decimals());
    }

    function canTrigger(TTarget memory t) internal returns (bool yes) {
        if (lastPrice == 0) return false;
        else {
            uint256 price = getPrice();
            yes = t.descend ? price < lastPrice && price < t.priceTarget : price > lastPrice && price > t.priceTarget;
            lastPrice = price;
        }
    }

    function transferAction(address sender, address /*recipient*/) external {
        require(msg.sender == address(gTokenA) || msg.sender == address(gTokenB), "Unauthorized");
        if (sender != authorizedPool) return; // No action
        isOdd = ! isOdd;
        if (isOdd) return; // Both Friend Guardian Tokens must transfer for correct price calculation
        // !!! This needs improvement - use doubly linked list instead of an array (to do after the hackathon)
        for (uint256 i = 0; i < targets.length; i++) {
            if (address(targets[i].toGuard) != address(0) && canTrigger(targets[i])) {
                // Optimistically pay the caller
                uint256 toPay = targets[i].reward;
                targets[i].reward = 0; // Empty first to avoid reentry attack
                payable(tx.origin).transfer(toPay); // Optimistically
                // Now execute the price action
                targets[i].toGuard.priceAction(gTokenA.balanceOf(msg.sender), gTokenB.balanceOf(msg.sender));
                delete(targets[i]);
            }
        }    
    }
} 