// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LogisticVRGDA, VRGDA} from "../../src/LogisticVRGDA.sol";

contract MockLogisticVRGDA is LogisticVRGDA {
    constructor(
        int256 _targetPrice,
        int256 _priceDecreasePercent,
        int256 _maxSellable,
        int256 _timeScale
    ) VRGDA(_targetPrice, _priceDecreasePercent) LogisticVRGDA(_maxSellable, _timeScale) {}
}
