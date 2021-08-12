// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "ds-test/test.sol";

import "../Delegator.sol";
import "../mocks/GovernanceToken.sol";

contract DelegatorTest is DSTest {
   address delegatee = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
   Delegator delegator;
   GovernanceToken ctx;

   function setUp() public {
      ctx = new GovernanceToken(address(this), address(this), block.timestamp);
      delegator = new Delegator(delegatee, address(ctx));
   }

   function test_parameters() public {
      assertEq(delegator.owner(), address(this));
      assertEq(delegator.delegatee(), delegatee);
      assertEq(delegator.token(), address(ctx));
      assertEq(ctx.delegates(address(delegator)), delegatee);
   }
}
