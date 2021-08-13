// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/access/Ownable.sol";
import "./interfaces/IGovernanceToken.sol";
import "./Delegator.sol";

/**
 * @title Delegator Contract Factory
 * @author Cryptex.Finance
 * @notice Contract in charge of generating Delegator contracts, handling delegations and CTX balance map, rewards.
 */

contract DelegatorFactory is Ownable {
   address public immutable token;
   mapping(address => address) public delegatorToDelegatee;
   mapping(address => address) public delegateeToDelegator;

   constructor(address token_) {
      token = token_;
   }

   function createDelegator(address delegatee_) public {
      require(delegatee_ != address(0), "Delegatee can't be 0");
      require(
         delegateeToDelegator[delegatee_] == address(0),
         "Delegator already created"
      );
      Delegator delegator = new Delegator(delegatee_, token);
      delegateeToDelegator[delegatee_] = address(delegator);
      delegatorToDelegatee[address(delegator)] = delegatee_;
   }

   function delegate(address delegator_, uint96 amount_) public {}

   //   function stake(uint256 amount_) public onlyOwner {}
}
