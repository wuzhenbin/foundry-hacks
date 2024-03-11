// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {OverflowToken} from "../src/Overflow.sol";

contract OverflowTest is Test {
    OverflowToken public token;

    address public constant USER1 = address(1);
    address public constant USER2 = address(2);

    function setUp() public {
        token = new OverflowToken(100);
    }

    function testOverflow() public {
        uint256 thisBalance = token.balanceOf(address(this));
        uint256 userBalance = token.balanceOf(USER1);
        assertEq(thisBalance, 100);
        assertEq(userBalance, 0);

        token.transfer(USER1, 1000);
        thisBalance = token.balanceOf(address(this));
        userBalance = token.balanceOf(USER1);
        assertEq(thisBalance, type(uint256).max - 900 + 1);
        assertEq(userBalance, 1000);
    }
}
