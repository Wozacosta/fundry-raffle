// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity 0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        // local => deploy mocks, get local config
        // sepolia -> get sepolia config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        console.log("helper config vrf coordinator: %s", config.vrfCoordinator);
        console.log("HERE");

        if (config.subscriptionId == 0) {
            console.log("creating subscription");
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, ) = createSubscription.createSubscription(
                config.vrfCoordinator
            );
            // Fund it !
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                config.vrfCoordinator,
                config.subscriptionId,
                config.linkToken
            );
        }

        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId
        );
        return (raffle, helperConfig);
    }
}
