// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

error InsufficientBalance();
error InsufficientAllowance();

contract TokenTest is Test {
    Token public token;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    event Approval(address indexed, address indexed, uint256);
    event Transfer(address indexed, address indexed, uint256);

    function setUp() public {
        token = Token(HuffDeployer.deploy("Token"));
    }

    function test_mint() public {
        token.mint(alice, 10 ether);
        assertEq(token.balanceOf(alice), 10 ether);
        assertEq(token.totalSupply(), 10 ether);

        token.mint(bob, 5 ether);
        assertEq(token.balanceOf(bob), 5 ether);
        assertEq(token.totalSupply(), 15 ether);

        token.mint(alice, 5 ether);
        assertEq(token.balanceOf(alice), 15 ether);
        assertEq(token.totalSupply(), 20 ether);
    }

    function test_burn() public {
        token.mint(alice, 7 ether);
        assertEq(token.balanceOf(alice), 7 ether);
        assertEq(token.totalSupply(), 7 ether);

        token.burn(alice, 3 ether);
        assertEq(token.balanceOf(alice), 4 ether);
        assertEq(token.totalSupply(), 4 ether);
    }

    function test_transfer() public {
        token.mint(alice, 3 ether);
        assertEq(token.balanceOf(alice), 3 ether);

        vm.prank(alice);
        token.transfer(bob, 1 ether);
        assertEq(token.balanceOf(alice), 2 ether);
        assertEq(token.balanceOf(bob), 1 ether);

        vm.prank(bob);
        token.transfer(alice, 0);
    }

    function test_transfer_return_value() public {
        token.mint(alice, 3 ether);

        vm.prank(alice);
        bool success = token.transfer(bob, 1 ether);
        assertTrue(success);
    }

    function test_transfer_insufficient_balance() public {
        vm.prank(alice);
        vm.expectRevert(InsufficientBalance.selector);
        token.transfer(bob, 1);
    }

    function test_transfer_from() public {
        token.mint(alice, 3 ether);
        assertEq(token.balanceOf(alice), 3 ether);

        vm.startPrank(alice);
        token.approve(alice, 1 ether);
        token.transferFrom(alice, bob, 1 ether);
        assertEq(token.balanceOf(alice), 2 ether);
        assertEq(token.balanceOf(bob), 1 ether);
        vm.stopPrank();
    }

    function test_transfer_from_insufficient_balance() public {
        vm.startPrank(alice);
        token.approve(alice, 1);

        vm.expectRevert(InsufficientBalance.selector);
        token.transferFrom(alice, bob, 1);
        vm.stopPrank();
    }

    function test_transfer_from_insufficient_allowance() public {
        vm.expectRevert(InsufficientAllowance.selector);
        token.transferFrom(alice, bob, 1);

        token.mint(alice, 1 ether);
        vm.prank(alice);
        token.approve(bob, 0.5 ether);

        assertEq(token.allowance(alice, bob), 0.5 ether);

        vm.expectRevert(InsufficientAllowance.selector);
        vm.prank(bob);
        token.transferFrom(alice, bob, 1 ether);
    }

    function test_transfer_from_allowance() public {
        token.mint(alice, 1 ether);
        vm.prank(alice);
        token.approve(bob, 0.5 ether);

        vm.prank(bob);
        vm.expectRevert(InsufficientAllowance.selector);
        token.transferFrom(alice, bob, 1 ether);
    }

    function test_transfer_from_reduces_allowance() public {
        token.mint(alice, 3 ether);

        vm.prank(alice);
        token.approve(bob, 3 ether);

        assertEq(token.allowance(alice, bob), 3 ether);

        vm.prank(bob);
        token.transferFrom(alice, bob, 1 ether);

        assertEq(token.allowance(alice, bob), 2 ether);
    }

    function test_transfer_from_max_approval_does_not_reduce_allowance() public {
        token.mint(alice, 3 ether);

        vm.prank(alice);
        token.approve(bob, type(uint256).max);

        assertEq(token.allowance(alice, bob), type(uint256).max);

        vm.prank(bob);
        token.transferFrom(alice, bob, 1 ether);

        assertEq(token.allowance(alice, bob), type(uint256).max);
    }

    function test_transfer_from_return_value() public {
        token.mint(alice, 3 ether);

        vm.prank(alice);
        token.approve(bob, 3 ether);

        vm.prank(bob);
        bool success = token.transferFrom(alice, bob, 1 ether);
        assertTrue(success);
    }

    function test_transfer_from_emits_event() public {
        token.mint(alice, 3 ether);

        vm.prank(alice);
        token.approve(bob, 3 ether);

        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 1 ether);

        vm.prank(bob);
        token.transferFrom(alice, bob, 1 ether);
    }

    function test_transfer_emits_event() public {
        token.mint(alice, 1 ether);

        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 1 ether);

        vm.prank(alice);
        token.transfer(bob, 1 ether);
    }

    function test_approval() public {
        vm.prank(alice);
        token.approve(bob, 100 ether);

        assertEq(token.allowance(alice, bob), 100 ether);

        vm.prank(alice);
        token.approve(bob, 5 ether);

        assertEq(token.allowance(alice, bob), 5 ether);
    }

    function test_approve_return_value() public {
        vm.prank(alice);
        bool success = token.approve(bob, 100 ether);
        assertTrue(success);
    }

    function test_approve_emits_event() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, 100 ether);

        vm.prank(alice);
        token.approve(bob, 100 ether);
    }

    function test_decimals() public {
        assertEq(token.decimals(), 18);
    }

    function test_name() public {
        assertEq(token.name(), "MyCoolToken");
    }

    function test_symbol() public {
        assertEq(token.symbol(), "COOL");
    }
}

interface Token {
    function mint(address, uint256) external;
    function burn(address, uint256) external;
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}
