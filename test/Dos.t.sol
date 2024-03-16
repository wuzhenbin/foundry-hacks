// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {DoS, DoSGame, DoSGameAttack} from "../src/DoS.sol";

contract DoSTest is Test {
    DoS public dos;
    DoSGame public dosGame;
    DoSGameAttack public doSGameAttack;

    address warmUpAddress = makeAddr("warmUp");
    address personA = makeAddr("A");
    address personB = makeAddr("B");
    address personC = makeAddr("C");

    address public constant alice = address(1);
    address public constant hacker = address(2);
    address public constant john = address(3);

    function setUp() public {
        dos = new DoS();
        dosGame = new DoSGame();
        doSGameAttack = new DoSGameAttack();

        deal(alice, 5 ether);
        deal(john, 1 ether);
        deal(hacker, 1 ether);
    }

    function testDenialOfService() public {
        // We want to warm up the storage stuff
        vm.prank(warmUpAddress);
        dos.enter();

        uint256 gasStartA = gasleft();
        vm.prank(personA);
        dos.enter();
        uint256 gasCostA = gasStartA - gasleft();

        uint256 gasStartB = gasleft();
        vm.prank(personB);
        dos.enter();
        uint256 gasCostB = gasStartB - gasleft();

        uint256 gasStartC = gasleft();
        vm.prank(personC);
        dos.enter();
        uint256 gasCostC = gasStartC - gasleft();

        console2.log("Gas cost A: %s", gasCostA);
        console2.log("Gas cost B: %s", gasCostB);
        console2.log("Gas cost C: %s", gasCostC);

        // The gas cost will just keep rising, making it harder and harder for new people to enter!
        assert(gasCostC > gasCostB);
        assert(gasCostB > gasCostA);
    }

    function testDosGame() public {
        vm.prank(alice);
        dosGame.deposit{value: 5 ether}();

        vm.prank(hacker);
        doSGameAttack.attack{value: 1 ether}(address(dosGame));

        vm.startPrank(john);
        dosGame.deposit{value: 1 ether}();
        vm.expectRevert(bytes("Refund Fail!"));
        dosGame.refund();
        vm.stopPrank();
    }
}
