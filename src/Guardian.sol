// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/interfaces/IERC20.sol";
import "./interfaces/IGuarded.sol";
import "./interfaces/IGuardian.sol";
import "./GuardianToken.sol";

contract Guardian is IGuardian {
    mapping (address => bool) isAuthorizedPool;
    IGuarded[] public toGuard;
    IGuardianToken[2] sourceTokens;

    constructor (IERC20 tokenA, IERC20 tokenB, address[] memory authorizedPools) {
        sourceTokens[0] = new GuardianToken(tokenA);
        sourceTokens[1] = new GuardianToken(tokenB);
        for (uint256 i = 0; i < authorizedPools.length; i++)
            isAuthorizedPool[authorizedPools[i]] = true;
    }

    function getTokenPair() external view returns (IGuardianToken tokenA, IGuardianToken tokenB) {
        return (sourceTokens[0], sourceTokens[1]);
    }

    function getUnderlyingTokenPair() external view returns (IERC20 tokenA, IERC20 tokenB) {
        return (sourceTokens[0].underlyingToken(), sourceTokens[1].underlyingToken());
    }

    function registerCallback(IGuarded guarded) external {
        toGuard.push(guarded);
    }

    function transferAction(address sender, address recipient) external {
        require(msg.sender == address(sourceTokens[0]) || msg.sender == address(sourceTokens[1]), "Unauthorized");
require(false, "Not implemented - check conditions - both tokens need action");
        if (! (isAuthorizedPool[sender] || isAuthorizedPool[recipient])) return; // No action
        // !!! This needs improvement - use doubly linked list instead of an array (to do after the hackathon
        for (uint256 i = 0; i < toGuard.length; i++) {
            if (address(toGuard[i]) != address(0)) {
                toGuard[i].priceAction(sourceTokens[0].balanceOf(msg.sender), sourceTokens[1].balanceOf(msg.sender));
                delete(toGuard[i]);
            }
        }    
    }
} 