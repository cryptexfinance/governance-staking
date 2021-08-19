// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/access/Ownable.sol";
import "./interfaces/IGovernanceToken.sol";
import "./Delegator.sol";
import "ds-test/test.sol";

/**
 * @title Delegator Contract Factory
 * @author Cryptex.Finance
 * @notice Contract in charge of generating Delegator contracts, handling delegations and CTX balance map, rewards.
 */

contract DelegatorFactory is Ownable, DSTest {
   address public immutable token;
   mapping(address => address) public delegatorToDelegatee;
   mapping(address => address) public delegateeToDelegator;
   mapping(address => bool) public delegators;

   event DelegatorCreated(
      address indexed _delegator,
      address indexed _delegatee
   );
   event Delegated(
      address indexed _delegator,
      address indexed _delegatee,
      uint96 _amount
   );
   event Undelegated(
      address indexed _delegator,
      address indexed _delegatee,
      uint96 _amount
   );

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
      delegators[address(delegator)] = true;
      emit DelegatorCreated(address(delegator), delegatee_);
   }

   function delegate(address delegator_, uint96 amount_) public {
      require(delegators[delegator_], "Not a valid delegator");
      require(amount_ > 0, "Amount must be greater than 0");
      Delegator d = Delegator(delegator_);
      IGovernanceToken(token).transferFrom(msg.sender, delegator_, amount_);
      d.stake(msg.sender, amount_);
      emit Delegated(delegator_, msg.sender, amount_);
   }

   function unDelegate(address delegator_, uint96 amount_) public {
      require(delegators[delegator_], "Not a valid delegator");
      require(amount_ > 0, "Amount must be greater than 0");
      Delegator d = Delegator(delegator_);
      d.removeStake(msg.sender, amount_);
      emit Undelegated(delegator_, msg.sender, amount_);
   }
}
