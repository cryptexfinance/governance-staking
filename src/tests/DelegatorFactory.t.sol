// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "ds-test/test.sol";

import "../Delegator.sol";
import "../DelegatorFactory.sol";
import "../mocks/GovernanceToken.sol";

contract User {
   function doCreateDelegator(DelegatorFactory d, address delegatee) public {
      d.createDelegator(delegatee);
   }

   function doStake(Delegator s, uint256 amount) public {
      //      s.stake(amount);
   }
}

contract DelegatorFactoryTest is DSTest {
   DelegatorFactory delegatorFactory;
   GovernanceToken ctx;
   User user1;

   function setUp() public {
      ctx = new GovernanceToken(address(this), address(this), block.timestamp);
      delegatorFactory = new DelegatorFactory(address(ctx));
      user1 = new User();
   }

   function test_parameters() public {
      assertEq(delegatorFactory.owner(), address(this));
      assertEq(delegatorFactory.token(), address(ctx));
   }

   function test_createDelegator(address delegatee) public {
      if (delegatee == address(0)) return;
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);
      Delegator d = Delegator(delegator);
      assertEq(d.delegatee(), delegatee);
      assertEq(delegatorFactory.delegateeToDelegator(delegatee), address(d));
      assertEq(delegatorFactory.delegatorToDelegatee(address(d)), delegatee);
   }

   function testFail_invalidCreateDelegator() public {
      delegatorFactory.createDelegator(address(0));
   }

   function testFail_createDelegator(address delegatee) public {
      delegatorFactory.createDelegator(delegatee);
      delegatorFactory.createDelegator(delegatee);
   }

   function test_delegateTo(address delegatee, uint96 amount) public {
      if (amount > ctx.totalSupply()) return;
      if (delegatee == address(0)) return;
      ctx.transfer(address(user1), amount);
      uint256 prevBalStaker = ctx.balanceOf(address(user1));
      uint256 prevBalDelegatee = ctx.balanceOf(delegatee);
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);
      uint256 prevBalDelegator = ctx.balanceOf(delegator);
      assertEq(prevBalStaker, amount);
      assertEq(prevBalDelegatee, 0);
      assertEq(prevBalDelegator, 0);

      // Delegate
      delegatorFactory.delegate(delegatee, amount);
      uint256 balStaker = ctx.balanceOf(address(user1));
      uint256 balDelegatee = ctx.balanceOf(delegatee);
      uint256 balDelegator = ctx.balanceOf(delegator);
      assertEq(balStaker, 0);
      assertEq(balDelegatee, 0);
      assertEq(balDelegator, amount);
      assertEq(ctx.getCurrentVotes(delegatee), amount);

      //delegation amount should increase also
   }

   // User should be able to delegate to multiple delegators
   // user should be able to move their delegation from one account to another
   // user should be able to move all their delegation from one account to another
   // user should be able to get back their stake
   // user should be able to get back all their stake
   // user should earn ctx
   // user should claim ctx rewards
}
