// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {SelfDestructEtherGame, SelfDestructAttack, SelfDestructEtherGameV2} from "../src/SelfDestruct.sol";

contract ReentrancyTest is Test {
    SelfDestructEtherGame public etherGame;
    SelfDestructEtherGameV2 public etherGameV2;
    SelfDestructAttack public attack;

    address public constant alice = address(1);
    address public constant chris = address(2);
    address public constant kevin = address(3);
    address public constant hacker = address(5);

    function setUp() public {
        vm.deal(alice, 10 ether);
        vm.deal(chris, 10 ether);
        vm.deal(kevin, 10 ether);
        vm.deal(hacker, 10 ether);
    }

    function testAttackSuccessful() public {
        etherGame = new SelfDestructEtherGame();
        attack = new SelfDestructAttack(address(etherGame));

        vm.prank(alice);
        etherGame.deposit{value: 1 ether}();

        vm.prank(chris);
        etherGame.deposit{value: 1 ether}();

        uint256 gameBalance = address(etherGame).balance;
        assertEq(gameBalance, 2 ether);

        vm.prank(hacker);
        attack.attack{value: 5 ether}();

        gameBalance = address(etherGame).balance;
        assertEq(gameBalance, 7 ether);

        vm.prank(kevin);
        vm.expectRevert(bytes("Game is over"));
        etherGame.deposit{value: 1 ether}();
    }

    function testAttackFailWithFixed() public {
        etherGameV2 = new SelfDestructEtherGameV2();
        attack = new SelfDestructAttack(address(etherGameV2));

        vm.prank(alice);
        etherGameV2.deposit{value: 1 ether}();

        vm.prank(chris);
        etherGameV2.deposit{value: 1 ether}();

        uint256 gameBalance = address(etherGameV2).balance;
        assertEq(gameBalance, 2 ether);

        vm.prank(hacker);
        attack.attack{value: 5 ether}();

        vm.prank(kevin);
        etherGameV2.deposit{value: 1 ether}();

        gameBalance = address(etherGameV2).balance;
        assertEq(gameBalance, 8 ether);

        uint256 gameValue = etherGameV2.balance();
        assertEq(gameValue, 3 ether);
    }
}
