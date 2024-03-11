// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {SelectorClash} from "../src/SelectorClash.sol";

/* 
https://openchain.xyz/signatures?query=0x41973cd9
putCurEpochConPubKeyBytes(bytes) - 0x41973cd9

f1121318093(bytes,bytes,uint64)
func10487987874260605968(bytes,bytes,uint64)
zttmoca(bytes,bytes,uint64)
*/

contract SelectorClashTest is Test {
    SelectorClash public selectorClash;

    function setUp() public {
        selectorClash = new SelectorClash();
    }

    function testPutCurEpochNotOwner() public {
        vm.expectRevert(bytes("Not Owner"));
        selectorClash.putCurEpochConPubKeyBytes("0x");
    }

    function testPutCurEpochSuccess() public {
        bool solved = selectorClash.solved();
        assertEq(solved, false);
        selectorClash.executeCrossChainTx("zttmoca", "0x", "0x", 0);
        solved = selectorClash.solved();
        assertEq(solved, true);
    }
}
