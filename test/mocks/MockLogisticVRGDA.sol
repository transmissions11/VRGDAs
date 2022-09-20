// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LogisticVRGDA} from "../../src/LogisticVRGDA.sol";

contract MockLogisticVRGDA is LogisticVRGDA {
    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _maxSellable,
        int256 _timeScale
    ) LogisticVRGDA(_targetPrice, _priceDecayPercent, _maxSellable, _timeScale) {}
}
