// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {SigReplay} from "../src/SigReplay.sol";

/* 
cast wallet sign "" --private-key 0000000000000000000000000000000000000000000000000000000000000001
*/

contract SigReplayTest is Test {
    SigReplay public sigReplay;
    address alice;
    uint256 alicePk;

    function setUp() public {
        (address aliceAddress, uint256 alicePrivateKey) = makeAddrAndKey("alice");
        alice = aliceAddress;
        alicePk = alicePrivateKey;
        vm.prank(alice);
        sigReplay = new SigReplay();
    }

    function testMint() public {
        bytes32 message = keccak256(abi.encodePacked(alice, uint256(1000)));
        bytes32 msgHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, msgHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        sigReplay.badMint(alice, 1000, signature);
        sigReplay.badMint(alice, 1000, signature);

        uint256 balance = sigReplay.balanceOf(alice);
        assertEq(balance, 2000);
    }
}
