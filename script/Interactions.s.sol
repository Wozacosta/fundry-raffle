// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CodeConstants} from "script/HelperConfig.s.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

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

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether; // 3 LINK

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().linkToken;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkToken
    ) public {
        console2.log(
            "Funding subscription %s on chainId: %s",
            subscriptionId,
            block.chainid
        );
        console2.log("Using vrfCoordinator: %s", vrfCoordinator);
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            // NOTE: we could use LinkToken interface form import {LinkTokenInterface} from
            // "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
            // more info here: https://docs.chain.link/vrf/v2/subscription/examples/programmatic-subscription#subscription-manager-contract
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
        console2.log("Subscription funded with %s LINK", FUND_AMOUNT);
    }

    function run() public {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subscriptionId);
    }

    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint256 subId
    ) public {
        console2.log("Adding consumer to VRF coordinator: %s", vrfCoordinator);
        console2.log("Consumer contract: %s", contractToAddToVrf);
        console2.log(
            "Subscription ID: %s on chain ID: %s",
            subId,
            block.chainid
        );
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedRaffleContract = DevOpsTools
            .get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployedRaffleContract);
    }
}
