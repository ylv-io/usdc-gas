// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <=0.9.0;

import "forge-std/Test.sol";
import "../src/FiatToken.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract USDCTest is Test {
    FiatTokenV2_1 public token;
    FiatTokenV2_1 public proxy;

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
        proxy = FiatTokenV2_1(address(new ERC1967Proxy(
            address(token),
            abi.encodeWithSignature(
                "initialize(string,string,string,uint8,address,address,address,address)",
                "USD Coin",
                "USDC",
                "USD",
                6,
                alice,
                alice,
                alice,
                alice
            )
        )));

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(bob, "frank");

        vm.prank(alice);
        proxy.configureMinter(alice, 9000000);

        vm.prank(alice);
        proxy.mint(alice, 1000000);

        vm.prank(alice);
        proxy.mint(frank, 1);
    }

    function testTransfer() public {
        vm.prank(alice);

        proxy.transfer(bob, 1000000);

        assertEq(proxy.balanceOf(alice), 0);
        assertEq(proxy.balanceOf(bob), 1000000);
    }

    function testTransferToNonEmptyAccount() public {
        vm.prank(alice);
        proxy.transfer(frank, 1);

        assertEq(proxy.balanceOf(frank), 2);
    }

    function testTransferHot() public {
        vm.prank(alice);
        proxy.transfer(frank, 1);

        vm.prank(frank);
        proxy.transfer(alice, 1);

        assertEq(proxy.balanceOf(frank), 1);
    }
}
