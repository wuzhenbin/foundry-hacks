// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/* 
goal - call putCurEpochConPubKeyBytes function 
*/

contract SelectorClash {
    // 攻击是否成功
    bool public solved;

    function putCurEpochConPubKeyBytes(bytes memory _bytes) public {
        require(msg.sender == address(this), "Not Owner");
        solved = true;
    }

    function executeCrossChainTx(bytes memory _method, bytes memory _bytes, bytes memory _bytes1, uint64 _num)
        public
        returns (bool success)
    {
        (success,) = address(this).call(
            abi.encodePacked(
                bytes4(keccak256(abi.encodePacked(_method, "(bytes,bytes,uint64)"))), abi.encode(_bytes, _bytes1, _num)
            )
        );
    }

    // function secretSlector() external pure returns (bytes4) {
    //     return bytes4(keccak256("putCurEpochConPubKeyBytes(bytes)"));
    // }

    // function hackSlector() external pure returns (bytes4) {
    //     return bytes4(keccak256("f1121318093(bytes,bytes,uint64)"));
    // }
}
