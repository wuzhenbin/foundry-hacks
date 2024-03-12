// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {ReentrancyBank, ReentrancyAttack, ReentrancyGoodBank, ReentrancyProtectedBank} from "../src/Reentrancy.sol";

contract ReentrancyTest is Test {
    ReentrancyBank public bank;
    ReentrancyAttack public attack;
    ReentrancyGoodBank public goodCEIBank;
    ReentrancyProtectedBank public goodProBank;

    address public constant alice = address(1);
    address public constant hacker = address(2);

    function setUp() public {
        bank = new ReentrancyBank();
        goodCEIBank = new ReentrancyGoodBank();
        goodProBank = new ReentrancyProtectedBank();

        vm.deal(alice, 1000 ether);
        vm.deal(hacker, 1 ether);
    }

    function testAttackSuccessful() public {
        attack = new ReentrancyAttack(address(bank));

        vm.prank(alice);
        bank.deposit{value: 20 ether}();

        uint256 bankBalance = address(bank).balance;
        uint256 attackBalance = address(attack).balance;

        assertEq(bankBalance, 20 ether);
        assertEq(attackBalance, 0);

        vm.prank(hacker);
        attack.attack{value: 1 ether}();

        bankBalance = address(bank).balance;
        attackBalance = address(attack).balance;

        assertEq(bankBalance, 0);
        assertEq(attackBalance, 21 ether);
    }

    function testAttackFailWithCEI() public {
        attack = new ReentrancyAttack(address(goodCEIBank));

        vm.prank(alice);
        goodCEIBank.deposit{value: 20 ether}();

        vm.expectRevert(bytes("Failed to send Ether"));
        vm.prank(hacker);
        attack.attack{value: 1 ether}();
    }

    function testAttackFailWithProtect() public {
        attack = new ReentrancyAttack(address(goodProBank));

        vm.prank(alice);
        goodProBank.deposit{value: 20 ether}();

        vm.expectRevert(bytes("Failed to send Ether"));
        vm.prank(hacker);
        attack.attack{value: 1 ether}();
    }
}
