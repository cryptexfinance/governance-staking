pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./GovernanceStaking.sol";

contract GovernanceStakingTest is DSTest {
    GovernanceStaking staking;

    function setUp() public {
        staking = new GovernanceStaking();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
