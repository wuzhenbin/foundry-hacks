// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {ReentrancyBank, ReentrancyAttack, ReentrancyGoodBank, ReentrancyProtectedBank} from "../src/Reentrancy.sol";

contract CounterTest is Test {
    ReentrancyBank public bank;
    ReentrancyAttack public attack;
    ReentrancyGoodBank public goodCEIBank;
    ReentrancyProtectedBank public goodProBank;

    address public constant USER = address(1);
    address public constant ATTACKER = address(2);

    function setUp() public {
        bank = new ReentrancyBank();
        goodCEIBank = new ReentrancyGoodBank();
        goodProBank = new ReentrancyProtectedBank();

        vm.deal(USER, 1000 ether);
        vm.deal(ATTACKER, 1 ether);
    }

    function testAttackSuccessful() public {
        attack = new ReentrancyAttack(address(bank));

        vm.prank(USER);
        bank.deposit{value: 20 ether}();

        uint256 bankBalance = address(bank).balance;
        uint256 attackBalance = address(attack).balance;

        assertEq(bankBalance, 20 ether);
        assertEq(attackBalance, 0);

        vm.prank(ATTACKER);
        attack.attack{value: 1 ether}();

        bankBalance = address(bank).balance;
        attackBalance = address(attack).balance;

        assertEq(bankBalance, 0);
        assertEq(attackBalance, 21 ether);
    }

    function testAttackFailWithCEI() public {
        attack = new ReentrancyAttack(address(goodCEIBank));

        vm.prank(USER);
        goodCEIBank.deposit{value: 20 ether}();

        vm.expectRevert(bytes("Failed to send Ether"));
        vm.prank(ATTACKER);
        attack.attack{value: 1 ether}();
    }

    function testAttackFailWithProtect() public {
        attack = new ReentrancyAttack(address(goodProBank));

        vm.prank(USER);
        goodProBank.deposit{value: 20 ether}();

        vm.expectRevert(bytes("Failed to send Ether"));
        vm.prank(ATTACKER);
        attack.attack{value: 1 ether}();
    }
}
