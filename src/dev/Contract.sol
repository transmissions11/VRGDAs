// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinearVRGDALib, LinearVRGDAx} from "./LinearVRGDALib.sol";
import {LogisticVRGDALib, LogisticVRGDAx} from "./LogisticVRGDALib.sol";

contract Contract {
    using LinearVRGDALib for LinearVRGDAx;
    using LogisticVRGDALib for LogisticVRGDAx;

    int256 resourceA;
    int256 resourceB;

    LinearVRGDAx internal linearAuction;
    LogisticVRGDAx internal logAuction;

    constructor () {
        linearAuction = LinearVRGDALib.createLinearVRGDA(1e18, 0.2e18, 1e18);
        logAuction = LogisticVRGDALib.createLogisticVRGDA(1e18, 0.2e18, 100e18, 100e18);
    }

    function buyLinear(uint256 amount) public payable {
        uint256 price = linearAuction.getVRGDAPrice(resourceA);
        require(msg.value >= (price * amount), "Not enough ETH");
        
        resourceA += int256(amount);
    }

    function buyLogistic(uint256 amount) public payable {
        uint256 price = logAuction.getVRGDAPrice(resourceB);
        require(msg.value >= (price * amount), "Not enough ETH");
        
        resourceB += int256(amount);
    }

    function getPriceLinear() public view returns (uint256) {
        return linearAuction.getVRGDAPrice(resourceA);
    }

    function getPriceLogistic() public view returns (uint256) {
        return logAuction.getVRGDAPrice(resourceB);
    }
}