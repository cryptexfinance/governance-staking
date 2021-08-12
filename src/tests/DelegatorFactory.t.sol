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
   }

   function test_parameters() public {
      assertEq(delegatorFactory.owner(), address(this));
      assertEq(delegatorFactory.token(), address(ctx));
   }

   function test_createDelegator(address delegatee) public {
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
}
