// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinearVRGDALib, LinearVRGDAx} from "./LinearVRGDALib.sol";

contract Contract {
    using LinearVRGDALib for LinearVRGDAx;

    int256 resourceA;
    int256 resourceB;

    LinearVRGDAx internal vrgdaA;
    LinearVRGDAx internal vrgdaB;

    constructor () {
        vrgdaA = LinearVRGDALib.createLinearVRGDA(1e18, 0.2e18, 1e18);
        vrgdaB = LinearVRGDALib.createLinearVRGDA(0.5e18, 0.2e18, 2e18);
    }

    function buyA(uint256 amount) public payable {
        uint256 price = vrgdaA.getVRGDAPrice(resourceA);
        require(msg.value >= (price * amount), "Not enough ETH");
        
        resourceA += int256(amount);
    }

    function buyB(uint256 amount) public payable {
        uint256 price = vrgdaB.getVRGDAPrice(resourceB);
        require(msg.value >= (price * amount), "Not enough ETH");
        
        resourceB += int256(amount);
    }

    function getPriceA() public view returns (uint256) {
        return vrgdaA.getVRGDAPrice(resourceA);
    }

    function getPriceB() public view returns (uint256) {
        return vrgdaB.getVRGDAPrice(resourceB);
    }
}