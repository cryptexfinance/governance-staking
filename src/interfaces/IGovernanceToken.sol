// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IGovernanceToken {
   function delegate(address delegatee) external;

   function delegates(address delegator) external returns (address);
}
