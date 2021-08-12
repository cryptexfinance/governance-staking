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

   constructor(address delegatee_, address token_) {
      token = token_;
      IGovernanceToken(token_).delegate(delegatee_);
   }

   function delegatee() public returns (address) {
      return IGovernanceToken(token).delegates(address(this));
   }
}
