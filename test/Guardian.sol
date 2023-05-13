// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GuardianFactory.sol";
import "../src/interfaces/IGuardian.sol";
import "../src/interfaces/IGuarded.sol";
import "../src/interfaces/IGuardianToken.sol";
import "../src/ERC20.sol";
import "../src/mock/MockUniswapV2Factory.sol";
import "../src/mock/interfaces/IUniswapV2Pair.sol";
import "../src/AaveLiquidator.sol";

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

        // Create Guardian
        IGuardian guardian = factory.createGuardian(GHO, PEPE);

        // Wrap tokens
        (gGHO, gPEPE) = guardian.getTokenPair();
        GHO.approve(address(gGHO), type(uint256).max);
        PEPE.approve(address(gPEPE), type(uint256).max);
        gGHO.wrap(10 * 10**GHO.decimals()); // 10 GHO
        gPEPE.wrap(10 * 10**9 * 10**gPEPE.decimals()); // 10 billion GHO

        // Create mock Uniswap V2 liquidity pool
        IUniswapV2Factory f = new MockUniswapV2Factory();
        IUniswapV2Pair pool = IUniswapV2Pair(f.createPair(address(gGHO), address(gPEPE)));
        // Put liquidity in the pool
        gGHO.transfer(address(pool), 1 * 10**gGHO.decimals()); // 1 gGHO
        gPEPE.transfer(address(pool), 1 * 10**9 * 10**gPEPE.decimals()); // 1 billion gPEPE

        // Authorize pool
        guardian.setAuthorizedPool(address(pool));
        
        // Create mock Aave position

        // Create a Guardian target
        AaveLiquidator l = new AaveLiquidator(guardian);
        payable(address(l)).transfer(2 ether); // Fund the liquidator, so he can pay the reward
        l.registerCallback(9, true, 1 ether); // Offer reward of 1 ether for calling Aave liquidation

        // Observe the amount of price actions
        assertEq(l.priceActionCount(), 0, "No actions yet");

        // Trade on Uniswap
        gPEPE.transfer(address(pool), 1 * 10**9 * 10**gPEPE.decimals()); // 1 billion gPEPE
        pool.swap(1 * 10**(gGHO.decimals()-1), 0, address(this), ""); // for 0.5 gGHO
        // Now the pool has 0.5 gGHO and 2 billion PEPE - the price has dropped

        // Observe liquidation on Aave
        assertEq(l.priceActionCount(), 1, "We should receive a single price action (not 2)");
    }
}
