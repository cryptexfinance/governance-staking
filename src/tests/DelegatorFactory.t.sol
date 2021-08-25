// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "ds-test/test.sol";

import "../Delegator.sol";
import "../DelegatorFactory.sol";
import "../mocks/GovernanceToken.sol";

contract User {
   function approveAmount(
      GovernanceToken t,
      DelegatorFactory d,
      uint96 a
   ) public {
      t.approve(address(d), a);
   }

   function doCreateDelegator(DelegatorFactory d, address delegatee) public {
      d.createDelegator(delegatee);
   }

   function doDelegate(
      DelegatorFactory d,
      address delegator,
      uint96 amount
   ) public {
      d.delegate(delegator, amount);
   }

   function doRemoveDelegate(
      DelegatorFactory d,
      address delegator,
      uint96 amount
   ) public {
      d.unDelegate(delegator, amount);
   }

   function doUpdateWaitTime(DelegatorFactory d, uint256 waitTime) public {
      d.updateWaitTime(waitTime);
   }
}

contract FakeDelegator {
   function stake(address staker_, uint96 amount_) public {
      // do nothing and keep funds
   }

   function removeStake(address staker_, uint96 amount_) public {
      // do nothing and keep funds
   }
}

contract DelegatorFactoryTest is DSTest {
   DelegatorFactory delegatorFactory;
   GovernanceToken ctx;
   User user1;
   uint256 waitTime = 1 weeks;

   function setUp() public {
      hevm = Hevm(HEVM_ADDRESS);
      ctx = new GovernanceToken(address(this), address(this), block.timestamp);
      delegatorFactory = new DelegatorFactory(
         address(ctx),
         address(ctx),
         waitTime,
         address(this)
      );
      user1 = new User();
   }

   function test_parameters() public {
      assertEq(delegatorFactory.owner(), address(this));
      assertEq(delegatorFactory.stakingToken(), address(ctx));
      assertEq(delegatorFactory.waitTime(), waitTime);
      assertEq(delegatorFactory.rewardsToken(), address(ctx));
   }

   function test_createDelegator(address delegatee) public {
      if (delegatee == address(0)) return;
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);
      Delegator d = Delegator(delegator);
      assertEq(d.delegatee(), delegatee);
      assertEq(delegatorFactory.delegateeToDelegator(delegatee), address(d));
      assertEq(delegatorFactory.delegatorToDelegatee(address(d)), delegatee);
      assertEq(d.owner(), address(delegatorFactory));
   }

   function testFail_invalidCreateDelegator() public {
      delegatorFactory.createDelegator(address(0));
   }

   function testFail_createDelegator(address delegatee) public {
      delegatorFactory.createDelegator(delegatee);
      delegatorFactory.createDelegator(delegatee);
   }

   function test_delegate(address delegatee, uint96 amount) public {
      if (amount > ctx.totalSupply()) return;
      if (amount == 0) return;
      if (delegatee == address(0)) return;

      // create delegator
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);

      uint256 prevBalDelegator = ctx.balanceOf(delegator);
      uint256 prevBalStaker = ctx.balanceOf(address(this));
      uint256 prevBalDelegatee = ctx.balanceOf(delegatee);
      assertEq(prevBalDelegatee, 0);
      assertEq(prevBalDelegator, 0);

      // Delegate
      ctx.approve(address(delegatorFactory), amount);
      delegatorFactory.delegate(delegator, amount);

      uint256 balDelegatee = ctx.balanceOf(delegatee);
      uint256 balDelegator = ctx.balanceOf(delegator);
      assertEq(ctx.balanceOf(address(this)), prevBalStaker - amount);
      assertEq(balDelegatee, 0);
      assertEq(balDelegator, amount);
      assertEq(ctx.getCurrentVotes(delegatee), amount);
      assertEq(
         delegatorFactory.stakerWaitTime(address(this), delegator),
         waitTime
      );
   }

   function testFail_invalidDelegator() public {
      uint96 amount = 1 ether;
      ctx.transfer(address(user1), amount);
      FakeDelegator faker = new FakeDelegator();
      user1.approveAmount(ctx, delegatorFactory, amount);
      user1.doDelegate(delegatorFactory, address(faker), amount);
   }

   function testFail_invalidAmount() public {
      address delegatee = address(0x1);
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);
      delegatorFactory.delegate(delegator, 0);
   }

   function test_multipleDelegators(uint96 amount, uint96 amount2) public {
      if (amount > ctx.totalSupply() / 2 || amount2 > ctx.totalSupply() / 2)
         return;
      if (amount == 0 || amount2 == 0) return;
      uint256 prevBalStaker = ctx.balanceOf(address(this));
      address delegatee1 = address(0x1);
      address delegatee2 = address(0x2);
      delegatorFactory.createDelegator(delegatee1);
      delegatorFactory.createDelegator(delegatee2);
      address delegator1 = delegatorFactory.delegateeToDelegator(delegatee1);
      address delegator2 = delegatorFactory.delegateeToDelegator(delegatee2);
      ctx.approve(address(delegatorFactory), amount + amount2);
      delegatorFactory.delegate(delegator1, amount);
      hevm.warp(waitTime);
      delegatorFactory.delegate(delegator2, amount2);

      assertEq(
         ctx.balanceOf(address(this)),
         prevBalStaker - (amount + amount2)
      );
      assertEq(ctx.balanceOf(delegator1), amount);
      assertEq(ctx.balanceOf(delegator2), amount2);
      assertEq(ctx.getCurrentVotes(delegatee1), amount);
      assertEq(ctx.getCurrentVotes(delegatee2), amount2);
      assertEq(
         delegatorFactory.stakerWaitTime(address(this), delegator1),
         waitTime
      );
      assertEq(
         delegatorFactory.stakerWaitTime(address(this), delegator2),
         2 weeks
      );
   }

   function test_unDelegate(address delegatee, uint96 amount) public {
      if (amount > ctx.totalSupply()) return;
      if (amount == 0) return;
      if (delegatee == address(0)) return;

      // create delegator
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);

      uint256 prevBalStaker = ctx.balanceOf(address(this));

      // Delegate
      ctx.approve(address(delegatorFactory), amount);
      delegatorFactory.delegate(delegator, amount);

      // Time Skip
      hevm.warp(waitTime + 1 seconds);

      // Remove Delegate
      delegatorFactory.unDelegate(delegator, amount);
      uint256 balDelegatee = ctx.balanceOf(delegatee);
      uint256 balDelegator = ctx.balanceOf(delegator);
      assertEq(ctx.balanceOf(address(this)), prevBalStaker);
      assertEq(balDelegatee, 0);
      assertEq(balDelegator, 0);
      assertEq(ctx.getCurrentVotes(delegatee), 0);
   }

   function testFail_unDelegateNoWait(address delegatee, uint96 amount) public {
      // create delegator
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);

      // Delegate
      ctx.approve(address(delegatorFactory), amount);
      delegatorFactory.delegate(delegator, amount);

      // Remove Delegate
      delegatorFactory.unDelegate(delegator, (amount));
   }

   function test_unDelegateSpecific(
      address delegatee,
      uint96 amount,
      uint96 amount2
   ) public {
      if (amount > ctx.totalSupply() / 2 || amount2 > ctx.totalSupply() / 2)
         return;
      if (amount == 0 || amount2 == 0) return;
      if (delegatee == address(0)) return;

      // create delegator
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);

      uint256 prevBalStaker = ctx.balanceOf(address(this));

      // Delegate
      uint96 totalAmount = amount + amount2;
      ctx.approve(address(delegatorFactory), totalAmount);
      delegatorFactory.delegate(delegator, totalAmount);

      // Time Skip
      hevm.warp(waitTime + 1 seconds);

      // Remove Delegate
      delegatorFactory.unDelegate(delegator, amount);
      uint256 balDelegatee = ctx.balanceOf(delegatee);
      uint256 balDelegator = ctx.balanceOf(delegator);
      assertEq(ctx.balanceOf(address(this)), prevBalStaker - amount2);
      assertEq(balDelegatee, 0);
      assertEq(balDelegator, amount2);
      assertEq(ctx.getCurrentVotes(delegatee), amount2);

      // Remove Delegate
      delegatorFactory.unDelegate(delegator, amount2);
      balDelegatee = ctx.balanceOf(delegatee);
      balDelegator = ctx.balanceOf(delegator);
      assertEq(ctx.balanceOf(address(this)), prevBalStaker);
      assertEq(balDelegatee, 0);
      assertEq(balDelegator, 0);
      assertEq(ctx.getCurrentVotes(delegatee), 0);
   }

   function testFail_invalidRemoveDelegator() public {
      uint96 amount = 1 ether;
      FakeDelegator faker = new FakeDelegator();
      user1.doRemoveDelegate(delegatorFactory, address(faker), amount);
   }

   function testFail_invalidRemoveAmount() public {
      address delegatee = address(0x1);
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);
      // Time Skip
      hevm.warp(waitTime + 1 seconds);
      delegatorFactory.unDelegate(delegator, 0);
   }

   function testFail_invalidUnDelegateAmount(address delegatee, uint96 amount)
      public
   {
      // create delegator
      delegatorFactory.createDelegator(delegatee);
      address delegator = delegatorFactory.delegateeToDelegator(delegatee);

      // Delegate
      ctx.approve(address(delegatorFactory), amount);
      delegatorFactory.delegate(delegator, amount);

      // Time Skip
      hevm.warp(waitTime + 1 seconds);

      // Remove Delegate
      delegatorFactory.unDelegate(delegator, (amount + 1));
   }

   function test_moveDelegation(uint96 amount, uint96 amount2) public {
      if (amount > ctx.totalSupply() / 2 || amount2 > ctx.totalSupply() / 2)
         return;
      if (amount == 0 || amount2 == 0) return;

      uint256 prevBalStaker = ctx.balanceOf(address(this));
      address delegatee1 = address(0x1);
      address delegatee2 = address(0x2);
      delegatorFactory.createDelegator(delegatee1);
      delegatorFactory.createDelegator(delegatee2);
      address delegator1 = delegatorFactory.delegateeToDelegator(delegatee1);
      address delegator2 = delegatorFactory.delegateeToDelegator(delegatee2);
      uint96 totalAmount = amount + amount2;
      ctx.approve(address(delegatorFactory), totalAmount);
      delegatorFactory.delegate(delegator1, totalAmount);

      // Time Skip
      hevm.warp(waitTime + 1 seconds);

      delegatorFactory.unDelegate(delegator1, amount);
      ctx.approve(address(delegatorFactory), amount);
      delegatorFactory.delegate(delegator2, amount);

      assertEq(
         ctx.balanceOf(address(this)),
         prevBalStaker - (amount + amount2)
      );
      assertEq(ctx.balanceOf(delegator1), amount2);
      assertEq(ctx.balanceOf(delegator2), amount);
      assertEq(ctx.getCurrentVotes(delegatee1), amount2);
      assertEq(ctx.getCurrentVotes(delegatee2), amount);
      assertEq(
         delegatorFactory.stakerWaitTime(address(this), delegator2),
         2 weeks + 1 seconds
      );
   }

   function test_updateWaitTime(uint256 newTime) public {
      assertEq(delegatorFactory.waitTime(), waitTime);
      delegatorFactory.updateWaitTime(newTime);
      assertEq(delegatorFactory.waitTime(), newTime);
   }

   function testFail_updateWaitTimeNotAdmin(uint256 newTime) public {
      user1.doUpdateWaitTime(delegatorFactory, newTime);
   }

   // user should earn ctx
   // user should claim ctx rewards
}
