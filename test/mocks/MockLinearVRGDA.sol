// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinearVRGDA} from "../../src/LinearVRGDA.sol";

contract MockLinearVRGDA is LinearVRGDA {
    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _perTimeUnit
    ) LinearVRGDA(_targetPrice, _priceDecayPercent, _perTimeUnit) {}
}
