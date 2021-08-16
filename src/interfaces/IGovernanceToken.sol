// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IGovernanceToken {
   function delegate(address delegatee) external;

   function delegates(address delegator) external returns (address);

   function transfer(address dst, uint256 rawAmount) external returns (bool);
}
