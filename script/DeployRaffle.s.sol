// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription} from "script/Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        // local => deploy mocks, get local config
        // sepolia -> get sepolia config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        console.log("helper config vrf coordinator: %s", config.vrfCoordinator);
        console.log("HERE");
        vm.startBroadcast();

        if (config.subscriptionId == 0) {
            console.log("creating subscription");
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, ) = createSubscription.createSubscription(
                config.vrfCoordinator
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
        console.log("HERE 2");
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}
