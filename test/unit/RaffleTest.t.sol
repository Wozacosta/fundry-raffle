// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Raffle} from "src/Raffle.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleInitialState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    /*///////////////////////////////////
    //          Enter raffle           //
    ///////////////////////////////////*/

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(PLAYER);
        // Act / Assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enter();
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enter{value: entranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEnteringRaffleEmitsEvent() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        // emit RaffleEntered(makeAddr("toto")); // NOTE: this would fail
        // Assert
        raffle.enter{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterCalculatingRaffle() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
        // simulate time passing
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1); // best practice
        raffle.performUpkeep("");
        // Act / Assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
    }

    /*///////////////////////////////////
    //          Check upkeep           //
    ///////////////////////////////////*/

    function testCheckUpkeepReturnsFalseIfNoBalance() public {
        // Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1); // best practice
        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        // Assert
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsFalseIfRaffleIsntOpen() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
        // simulate time passing
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1); // best practice
        raffle.performUpkeep("");
        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        // Assert
        assert(!upkeepNeeded);
    }
    // TODO: more check upkeep tests

    /*///////////////////////////////////
    //          Perform upkeep         //
    ///////////////////////////////////*/

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
        // simulate time passing
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // Act / Assert
        raffle.performUpkeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        // Arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();

        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
        currentBalance = address(this).balance;
        numPlayers = raffle.getPlayers().length;
        // Act / Assert
        vm.expectRevert();
        raffle.performUpkeep(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                rState
            )
        );
    }

    function testFulfillRandomWords() public {
        // Enter the raffle with multiple participants
        address player1 = address(0x1);
        address player2 = address(0x2);
        address player3 = address(0x3);

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        vm.deal(player3, 1 ether);

        vm.prank(player1);
        raffle.enter{value: entranceFee}();

        vm.prank(player2);
        raffle.enter{value: entranceFee}();

        vm.prank(player3);
        raffle.enter{value: entranceFee}();

        // Perform upkeep to request random words
        vm.warp(block.timestamp + interval + 1);
        raffle.performUpkeep("");

        // Assert: Check if the upkeep was performed correctly and the state transitioned
        assert(raffle.getRaffleState() == Raffle.RaffleState.CALCULATING);

        // Simulate fulfilling random words using a mock VRF coordinator

        // uint256 requestId = 1; // Mock request ID
        // uint256[] memory randomWords;
        // randomWords[0] = uint256(keccak256(abi.encodePacked(block.timestamp))); // Mock random number

        // Call the fulfillRandomWords function directly (simulating VRF response)
        // raffle.fulfillRandomWords(requestId, randomWords);
        VRFCoordinatorV2_5Mock coordinator = VRFCoordinatorV2_5Mock(
            vrfCoordinator
        );
        console.log("before fulfill");
        vm.deal(vrfCoordinator, 1 ether);
        vm.prank(vrfCoordinator);

        coordinator.fulfillRandomWords(1, address(raffle));
        // Assert: Check the expected outcomes
        address recentWinner = raffle.getRecentWinner();
        console.log("Recent winner address:", recentWinner);
        assert(
            recentWinner == player1 ||
                recentWinner == player2 ||
                recentWinner == player3
        );

        // Verify that the raffle state has been reset
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        // Verify that the players array has been reset
        assertEq(raffle.getPlayers().length, 0);
    }
}
