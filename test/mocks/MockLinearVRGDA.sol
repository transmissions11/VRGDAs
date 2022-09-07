// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import {LinearVRGDA, VRGDA} from "../../src/LinearVRGDA.sol";
import {LinearVRGDA} from "../../src/LinearVRGDA.sol";

contract MockLinearVRGDA {
    int256 internal immutable perTimeUnit;
    int256 internal immutable priceDecayPercent;
    int256 public immutable targetPrice;

    constructor(
        int256 _targetPrice,
        int256 _priceDecreasePercent,
        int256 _perTimeUnit
    ) {
        targetPrice = _targetPrice;
        priceDecayPercent = _priceDecreasePercent;
        perTimeUnit = _perTimeUnit;
    }

    function getTargetSaleTime(int256 sold) public view returns (int256) {
        return LinearVRGDA.getTargetSaleTime(sold, perTimeUnit);
    }

    function getVRGDAPrice(int256 timeSinceStart, uint256 sold) public view returns (uint256) {
        return LinearVRGDA.getVRGDAPrice(timeSinceStart, targetPrice, priceDecayPercent, perTimeUnit, sold);
    }
}
