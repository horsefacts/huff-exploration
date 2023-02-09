// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract TokenTest is Test {
    Token public token;

    function setUp() public {
        token = Token(HuffDeployer.deploy("Token"));
    }

    function test_mint(address to, uint256 amount) public {
        token.mint(to, amount);
        assertEq(token.balanceOf(to), amount);
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
    function balanceOf(address) external view returns (uint256);
    function decimals() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}
