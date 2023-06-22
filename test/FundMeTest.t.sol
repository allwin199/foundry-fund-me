// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe, FundMe__NOT_ENOUGH_ETH} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

// we are inherting everything from Test contract
contract FundMeTest is Test {
    // Before testing we need the contract to be deployed.
    // setUp fn will always run first.

    FundMe public fundMe;
    HelperConfig public helperConfig;

    address public USER = makeAddr("user");
    uint256 public constant SEND_ETH_VALUE = 1e17; //0.1ETH
    uint256 public constant STARTING_USER_BALANCE = 10e18; //10ETH

    function setUp() external {
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function test_MinimumDollarIsFive() public {
        assertEq(fundMe.getMinimumUsd(), 5e18);
    }

    function test_OwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_PriceFeedIsSetAccordingToChainId() public {
        address retrievePriceFeed = fundMe.getPriceFeedAddress();
        address expectedPriceFeed = helperConfig.activeNetworkConfig();
        assertEq(retrievePriceFeed, expectedPriceFeed);
    }

    function test_GetVersionOfV3Interface() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function test_RevertIfNotEnoughEthSent() public {
        vm.expectRevert(); // It is expecting the next line should revert
        fundMe.fund();
    }

    function test_UpdatesTheAddressToAmountFunded() public {
        vm.prank(USER); // The next TX will be sent by the USER
        fundMe.fund{value: SEND_ETH_VALUE}(); // USER will call this fn and send ETH
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_ETH_VALUE);
        assertEq(fundMe.getFunder(0), USER);
    }
}
