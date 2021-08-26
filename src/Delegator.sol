// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/access/Ownable.sol";
import "./interfaces/IGovernanceToken.sol";
import "ds-test/test.sol";

/**
 * @title Delegator Contract
 * @author Cryptex.Finance
 * @notice Contract in charge of handling delegations.
 */

contract Delegator is Ownable, DSTest {
   address public immutable token;
   mapping(address => uint256) public stakerBalance;

   constructor(address delegatee_, address token_) {
      token = token_;
      IGovernanceToken(token_).delegate(delegatee_);
   }

   function delegatee() external returns (address) {
      return IGovernanceToken(token).delegates(address(this));
   }

   function stake(address staker_, uint256 amount_) external onlyOwner {
      stakerBalance[staker_] += amount_;
   }

   function removeStake(address staker_, uint256 amount_) external onlyOwner {
      stakerBalance[staker_] -= amount_;
      IGovernanceToken(token).transfer(staker_, amount_);
   }
}
