// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

// we are inherting everything from Test contract
contract FundMeTest is Test {
    // Before testing we need the contract to be deployed.
    // setUp fn will always run first.

    FundMe public fundMe;
    HelperConfig public helperConfig;

    address public USER = makeAddr("user");
    uint256 public constant SEND_ETH_VALUE = 1e17; //0.1ETH
    uint256 public constant STARTING_USER_BALANCE = 10e18; //10ETH
    uint256 public constant GAS_PRICE = 1; // price of 1 unit of gas

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

    function test_FundUpdatesTheAddressToAmountFundedDS() public {
        vm.prank(USER); // The next TX will be sent by the USER
        fundMe.fund{value: SEND_ETH_VALUE}(); // USER will call this fn and send ETH
        // modifier is not used, to understand the above lines.
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_ETH_VALUE);
    }

    // State Tree
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETH_VALUE}();
        _;
    }

    function test_AddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function test_RevertIfWithdrawIsNotCalledByOwner() public funded {
        vm.expectRevert();
        vm.prank(USER); // since it is also vm, expectRevert will ignore this line and expect next line to revert
        fundMe.withdraw();
    }

    function test_WithdrawWithASingleFunder() public funded {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function test_WithdrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        // To generate addresses from numbers, it should be uint160.
        // eg address(1); // this will give a new random address
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_ETH_VALUE}();
        }

        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        // uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assert(endingFundMeBalance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance == endingOwnerBalance
        );
        // Eventhough we are calling functions in the blockchain
        // No gas is used. This is because of Anvil
        // In Anvil gas price is default to 0.
    }
}

// To run all the test in local env
// forge test

// To simulate a Test net env
// forge test --fork-url $SEPOLIA_RPC_URL
