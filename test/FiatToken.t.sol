// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <=0.9.0;

import "forge-std/Test.sol";
import "../src/FiatToken.sol";

contract USDCTest is Test {
    FiatTokenV2_1 public token;

    address payable internal alice = payable(makeAddr("alice"));
    address payable internal bob = payable(makeAddr("bob"));
    address payable internal frank = payable(makeAddr("frank"));

    function setUp() public {
        token = new FiatTokenV2_1();
        token.initialize(
            "USD Coin",
            "USDC",
            "USD",
            6,
            alice,
            alice,
            alice,
            alice
        );

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(bob, "frank");

        vm.prank(alice);
        token.configureMinter(alice, 9000000);

        vm.prank(alice);
        token.mint(alice, 1000000);

        vm.prank(alice);
        token.mint(frank, 1);
    }

    function testTransfer() public {
        vm.prank(alice);

        token.transfer(bob, 1000000);

        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 1000000);
    }

    function testTransferToNonEmptyAccount() public {
        vm.prank(alice);
        token.transfer(frank, 1);

        assertEq(token.balanceOf(frank), 2);
    }

    function testTransferHot() public {
        vm.prank(alice);
        token.transfer(frank, 1);

        vm.prank(frank);
        token.transfer(alice, 1);

        assertEq(token.balanceOf(frank), 1);
    }
}
