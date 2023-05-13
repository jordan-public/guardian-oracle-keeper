// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GuardianFactory.sol";
import "../src/interfaces/IGuardian.sol";
import "../src/interfaces/IGuarded.sol";
import "../src/interfaces/IGuardianToken.sol";
import "../src/ERC20.sol";

contract GuardianTest is Test {
    // Test accounts from passphrase in env (not in repo)
    address constant account0 = 0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB;
    address constant account1 = 0xFE6A93054b240b2979F57e49118A514F75f66D4e;
    address constant account2 = 0xcEeEa627dDe5EF73Fe8625e146EeBba0fdEB00bd;
    address constant account3 = 0xEf5b07C0cb002853AdaD2B2E817e5C66b62d34E6;
    address constant account4 = 0x895652cB06D430D45662291b394253FF97dD8B9E;

    IGuardianFactory factory;

    function setUp() public {
        console.log("Creator (owner): ", msg.sender);

        // Deploy guardian factory
        factory = new GuardianFactory();
        console.log("Guardian Factory deployed: ", address(factory));
    }

    function testLiquidation() public {
        IERC20 GHO;
        IERC20 PEPE;
        IGuardianToken gGHO;
        IGuardianToken gPEPE;

        // Test USDC token
        GHO = new ERC20("Mock GHO", "GHO", 6, 10**6 * 10**6); // 1M total supply
        console.log("Test GHO address: ", address(GHO));
        PEPE = new ERC20("Mock PEPE", "PEPE", 18, 10**15 * 10**18); // 1 quadrillion total supply
        console.log("Test PEPE address: ", address(PEPE));

        // Create mock Uniswap V2 liquidity pool
        address pool;
        
        // Create Guardian
        IGuardian guardian = factory.createGuardian(GHO, PEPE, pool);

        // Wrap tokens
        (gGHO, gPEPE) = guardian.getTokenPair();
        GHO.approve(address(gGHO), type(uint256).max);
        PEPE.approve(address(gPEPE), type(uint256).max);
        gGHO.wrap(1 * 10**GHO.decimals()); // 1 GHO
        gPEPE.wrap(1 * 10**9 * 10**gPEPE.decimals()); // 1 billion GHO

        // Create mock Uniswap liquidity

        // Create mock Aave position

        // Trade on Uniswap

        // Observe liquidation
    }
}
