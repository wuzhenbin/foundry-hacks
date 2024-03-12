// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {SigReplay} from "../src/SigReplay.sol";

/* 
cast wallet sign "0x7a64aaa9fcb1565d5c8b5e89df9565f0188ca30a0ac874a95ac3079cdfe7664f" --private-key 0000000000000000000000000000000000000000000000000000000000000001
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

    function getMessageHash(address to, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(to, amount));
    }

    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function testMint() public {
        bytes32 _msgHash = toEthSignedMessageHash(getMessageHash(alice, 1000));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, _msgHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        sigReplay.badMint(alice, 1000, signature);
        sigReplay.badMint(alice, 1000, signature);

        uint256 balance = sigReplay.balanceOf(alice);
        assertEq(balance, 2000);
    }
}
