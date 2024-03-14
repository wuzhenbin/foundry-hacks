// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {ContractCheck, NotContract} from "../src/ContractCheck.sol";

contract ContractCheckTest is Test {
    ContractCheck public contractCheck;
    NotContract public notContract;

    address public constant alice = address(1);

    function setUp() public {
        contractCheck = new ContractCheck();
        notContract = new NotContract(address(contractCheck));
    }

    function testAttack() public {
        bool isContract = notContract.isContract();
        assertEq(isContract, false);

        uint256 balance = contractCheck.balanceOf(address(notContract));
        assertEq(balance, 1000);

        vm.expectRevert(bytes("Contract not allowed!"));
        notContract.mint();
    }
}
