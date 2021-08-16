// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/access/Ownable.sol";
import "./interfaces/IGovernanceToken.sol";

/**
 * @title Delegator Contract
 * @author Cryptex.Finance
 * @notice Contract in charge of handling delegations.
 */

contract Delegator is Ownable {
   address public immutable token;
   mapping(address => uint96) public stakerBalance;

   constructor(address delegatee_, address token_) {
      token = token_;
      IGovernanceToken(token_).delegate(delegatee_);
   }

   function delegatee() public returns (address) {
      return IGovernanceToken(token).delegates(address(this));
   }

   function stake(address staker_, uint96 amount_) public onlyOwner {
      stakerBalance[staker_] += amount_;
   }

   function removeStake(address staker_, uint96 amount_) public onlyOwner {
      stakerBalance[staker_] -= amount_;
      IGovernanceToken(token).transfer(staker_, amount_);
   }
}
