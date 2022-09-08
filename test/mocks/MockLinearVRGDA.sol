// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinearVRGDALib, LinearVRGDAx} from "../../src/LinearVRGDALib.sol";

contract MockLinearVRGDA {
    using LinearVRGDALib for LinearVRGDAx;
    LinearVRGDAx internal linearAuction;

    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _perTimeUnit
    ) {
        linearAuction = LinearVRGDALib.createLinearVRGDA(
            _targetPrice,
            _priceDecayPercent,
            _perTimeUnit
        );
    }

    function targetPrice() public view returns (int256) {
        return linearAuction.vrgda.targetPrice;
    }

    function getVRGDAPrice(int256 timeSinceStart, uint256 sold) public view returns (uint256) {
        return linearAuction.getVRGDAPrice(timeSinceStart, sold);
    }

    function getTargetSaleTime(int256 sold) public view returns (int256) {
        return LinearVRGDALib.getTargetSaleTime(linearAuction.perTimeUnit, sold);
    }
}
