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

contract CounterTest is Test {
    SelectorClash public selectorClash;

    address public constant USER = address(1);

    function setUp() public {
        selectorClash = new SelectorClash();
    }

    function testPutCurEpochNotOwner() public {
        vm.prank(USER);
        vm.expectRevert(bytes("Not Owner"));
        selectorClash.putCurEpochConPubKeyBytes("0x");
    }

    function testPutCurEpochSuccess() public {
        vm.prank(USER);
        selectorClash.executeCrossChainTx("zttmoca", "0x", "0x", 0);
    }
}
