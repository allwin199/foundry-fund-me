// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// similar to wallets, contracts can hold funds as well
// To receive fund, we have to make the function as payable

// cutom errors
error FundMe__NOT_OWNER();
error FundMe__WITHDRAW_FAILED();
error FundMe__NOT_ENOUGH_ETH();

contract FundMe {
    address private immutable i_owner;

    using PriceConverter for uint256;
    // Attaching PriceConverter library to all uin256
    // now all uint256 will have access to PriceConverter library

    uint256 private constant MINIMUM_USD = 5 * 1e18;
    // since priceInUsd will have 18 deciamls, we also need minimum usd to have 18 decimals;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    AggregatorV3Interface private s_priceFeed;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function fund() public payable {
        uint256 ethPriceInUsd = (msg.value).getConversionRate(s_priceFeed);
        // require(ethPriceInUsd >= MINIMUM_USD, "Minimum of 5 USD is required");
        if (ethPriceInUsd < MINIMUM_USD) revert FundMe__NOT_ENOUGH_ETH();
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // we are resetting the array.
        // (0) -> we are asking to start at 0.

        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        // require(sent, "Withdraw Failed!");
        // this has been modified to below statement for gas optimization
        // see onlyowner fn for more details
        if (!sent) revert FundMe__WITHDRAW_FAILED();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Only owner can withdraw");
        // we are storing this string as string array in memory
        // For example, a string "Hello" would be stored as an array of bytes [72, 101, 108, 108, 111],
        // where each byte represents the ASCII value of the corresponding character.

        // By using revert, we can return the error code instead of string
        if (msg.sender != i_owner) revert FundMe__NOT_OWNER();
        _;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        fund();
    }

    // Fallback function is called when msg.data is not empty
    // when we send some data, it will check whether it matches with any of the functions defined.
    // If none of the function is matched, it will look for the fallback()
    fallback() external payable {
        fund();
    }

    /**
     * View / Pure functions(Getters)
     */
    function getAddressToAmountFunded(
        address _fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[_fundingAddress];
    }

    function getFunder(uint256 _index) external view returns (address) {
        return s_funders[_index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getMinimumUsd() external pure returns (uint256) {
        return MINIMUM_USD;
    }

    function getPriceFeedAddress() external view returns (address) {
        return address(s_priceFeed);
    }
}

/*
           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */
