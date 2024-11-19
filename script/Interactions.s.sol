// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

/* Create a subscription 
https://docs.chain.link/vrf/v2-5/overview/subscription

Consumers: Consuming contracts that are approved
to use funding from your subscription account.

Subscription accounts:
An account that holds LINK and native tokens
and makes them available to fund requests to Chainlink VRF v2.5 coordinators.

Subscription id: 256-bit unsigned integer
representing the unique identifier of the subscription.

Subscription owner: The wallet address that creates and manages
a subscription account. Any account can add LINK or native tokens
to the subscription balance, but only the owner can
add approved consuming contracts or withdraw funds.
*/
contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        (uint256 subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
        // create subscription...
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256, address) {
        // create subscription...
        console2.log("Creating subscription on chainId: %s", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console2.log("Subscription ID is ", subId);
        console2.log(
            "Please update the subscription ID in the HelperConfig contract"
        );
        return (subId, vrfCoordinator);
    }

    function run() public {
        // Create a subscription
    }
}
