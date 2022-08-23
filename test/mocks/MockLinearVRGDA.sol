// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinearVRGDA, VRGDA} from "../../src/LinearVRGDA.sol";

contract MockLinearVRGDA is LinearVRGDA {
    constructor(
        int256 _targetPrice,
        int256 _priceDecreasePercent,
        int256 _perDay
    ) VRGDA(_targetPrice, _priceDecreasePercent) LinearVRGDA(_perDay) {}
}
