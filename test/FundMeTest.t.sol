// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// we are inherting everything from Test contract
contract FundMeTest is Test {
    // Before testing we need the contract to be deployed.
    // Let's deploy the contract
    // setUp fn will always run first

    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetVersionOfV3Interface() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
        ////////////////////////
        // If we run this test we will get "EvmError: Revert"
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306::version()
        // testfn is trying to call version() on this contract
        // but this contract is only available on sepolia testnet
        // while using local nodes(anvil) this will revert
        /////////////////////////
        // forge test --match-test testGetVersionOfV3Interface -vvvv --fork-url $SEPOLIA_RPC_URL
        // now when this test run, since fork url is provided anvil will simulate sepolia testnet.
    }
}
