// We are writing scripts to interact with the FundMe contract.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
    // the reason we are specifying chainid is, the custom script will go into the broadcast folder
    // and according to the specific chainid, it will get the recentlyDeployedContract.
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}

// To interact with the contract, the contract should be already deployed.
// anvil
// NOTE: for sepolia use $SEPOLIA_RPC_URL and $SEPOLIA_PRIVATE_KEY
// forge script script/DeployFundMe.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
// the above script will deploy the contract.
// let's interact with the contract using FundFundMe.
// forge script script/Interactions.s.sol:FundFundMe --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
// right now, the above script is not working for me.
