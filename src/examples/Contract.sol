// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinearVRGDALib, LinearVRGDAx} from "../LinearVRGDALib.sol";
import {LogisticVRGDALib, LogisticVRGDAx} from "../LogisticVRGDALib.sol";
import {toWadUnsafe} from "../utils/SignedWadMath.sol";

contract Contract {
    using LinearVRGDALib for LinearVRGDAx;
    using LogisticVRGDALib for LogisticVRGDAx;

    uint256 startTime = block.timestamp;

    // dummy counters to represent "purchases"
    int256 resourceA;  // priced via Linear VRGDA
    int256 resourceB;  // priced via Logistic VRGDA

    // define 2 VRGDAs to price the resources
    LinearVRGDAx internal linearAuction;
    LogisticVRGDAx internal logAuction;

    constructor () {
        // initialize the VRGDAs
        linearAuction = LinearVRGDALib.createLinearVRGDA(1e18, 0.2e18, 1e18);
        logAuction = LogisticVRGDALib.createLogisticVRGDA(1e18, 0.2e18, 100e18, 100e18);
    }

    // purchase resourceA, according to the linear VRGDA
    function buyLinear(uint256 amount) public payable {
        int256 timeSinceStart = toWadUnsafe(block.timestamp - startTime);
        uint256 price = linearAuction.getVRGDAPrice(timeSinceStart, resourceA);
        require(msg.value >= (price * amount), "Not enough ETH");
        
        resourceA += int256(amount);
    }

    // purchase resourceB, according to the logistic VRGDA
    function buyLogistic(uint256 amount) public payable {
        int256 timeSinceStart = toWadUnsafe(block.timestamp - startTime);
        uint256 price = logAuction.getVRGDAPrice(timeSinceStart, resourceB);
        require(msg.value >= (price * amount), "Not enough ETH");
        
        resourceB += int256(amount);
    }

    // view function for getting the price of resourceA
    function getPriceLinear() public view returns (uint256) {
        int256 timeSinceStart = toWadUnsafe(block.timestamp - startTime);
        return linearAuction.getVRGDAPrice(timeSinceStart, resourceA);
    }

    // view function for getting the price of resourceB
    function getPriceLogistic() public view returns (uint256) {
        int256 timeSinceStart = toWadUnsafe(block.timestamp - startTime);
        return logAuction.getVRGDAPrice(timeSinceStart, resourceB);
    }
}