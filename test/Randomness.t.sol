// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {RandomnessGuess, RandomnessAttack} from "../src/Randomness.sol";

contract RandomnessTest is Test {
    RandomnessGuess public randGuess;
    RandomnessAttack public attack;

    address public constant alice = address(1);

    function setUp() public {
        randGuess = new RandomnessGuess{value: 1 ether}();
        attack = new RandomnessAttack();
    }

    function testAttack() public {
        uint256 randGuessBalance = address(randGuess).balance;
        uint256 attackBalance = address(attack).balance;

        assertEq(randGuessBalance, 1 ether);
        assertEq(attackBalance, 0);

        attack.attack(randGuess);

        randGuessBalance = address(randGuess).balance;
        attackBalance = address(attack).balance;
        assertEq(randGuessBalance, 0);
        assertEq(attackBalance, 1 ether);
    }
}
