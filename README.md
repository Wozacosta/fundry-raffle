# Raffle Contract

## Overview

This is a simple Raffle contract implemented in Solidity. It uses Chainlink VRF v2.5 for randomness to pick a winner. The contract allows users to enter the raffle by paying an entrance fee. After a specified interval, a winner is picked randomly from the participants.

## Features

- Users can enter the raffle by paying an entrance fee.
- The contract uses Chainlink VRF v2.5 to ensure randomness in picking a winner.
- The raffle runs at specified intervals.
- The contract ensures that the raffle is only open when it should be and that it has enough funds to pay the winner.

## Contract Layout

- **Version**
- **Imports**
- **Errors**
- **Interfaces, Libraries, Contracts**
- **Type Declarations**
- **State Variables**
- **Events**
- **Modifiers**
- **Functions**

### Functions Layout

1. **Constructor**
2. **Receive Function** (if exists)
3. **Fallback Function** (if exists)
4. **External Functions**
5. **Public Functions**
6. **Internal Functions**
7. **Private Functions**
8. **View & Pure Functions**

## Usage

### Constructor

The constructor initializes the contract with the following parameters:

- `entranceFee`: The fee required to enter the raffle.
- `interval`: The time interval between raffle runs.
- `vrfCoordinator`: The address of the Chainlink VRF coordinator.
- `gasLane`: The gas lane key hash.
- `subscriptionId`: The subscription ID for Chainlink VRF.
- `callbackGasLimit`: The gas limit for the callback function.

### Entering the Raffle

To enter the raffle, users need to call the `enter` function and send the required entrance fee.

```solidity
function enter() external payable;


## Tests

1. Write deploy scripts
2. Write tests
    1. Local chain
    2. Forket testnet
    3. Forket mainnet


## Deploy on testnet

follow the end of https://updraft.cyfrin.io/courses/foundry/smart-contract-lottery/fund-subscription