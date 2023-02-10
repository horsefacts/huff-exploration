// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

error InsufficientBalance();

contract TokenTest is Test {
    Token public token;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

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
    }

    function test_transfer_insufficient_balance() public {
        vm.prank(alice);
        vm.expectRevert(InsufficientBalance.selector);
        token.transfer(bob, 1);
    }

    function test_transfer_from() public {
        token.mint(alice, 3 ether);
        assertEq(token.balanceOf(alice), 3 ether);

        vm.prank(alice);
        token.transferFrom(alice, bob, 1 ether);
        assertEq(token.balanceOf(alice), 2 ether);
        assertEq(token.balanceOf(bob), 1 ether);
    }

    function test_transfer_from_insufficient_balance() public {
        vm.prank(alice);
        vm.expectRevert(InsufficientBalance.selector);
        token.transferFrom(alice, bob, 1);
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
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external;
    function balanceOf(address) external view returns (uint256);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}
