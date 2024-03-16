// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test, console, console2} from "forge-std/Test.sol";
import {txOriginBank, txOriginAttack} from "../src/txOrigin.sol";

contract TxOriginTest is Test {
    txOriginBank public bank;
    txOriginAttack public attack;

    address public constant alice = address(1);
    address public constant hacker = address(2);

    function setUp() public {
        hoax(alice, 10 ether);
        bank = new txOriginBank{value: 10 ether}();

        vm.prank(hacker);
        attack = new txOriginAttack(bank);
    }

    function testAttack() public {
        uint256 bankBalance = address(bank).balance;
        uint256 hackerBalance = address(hacker).balance;

        assertEq(bankBalance, 10 ether);
        assertEq(hackerBalance, 0);

        vm.prank(alice, alice);
        attack.attack();

        bankBalance = address(bank).balance;
        hackerBalance = address(hacker).balance;

        assertEq(bankBalance, 0);
        assertEq(hackerBalance, 10 ether);
    }
}
