// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LogisticToLinearVRGDA} from "../../src/LogisticToLinearVRGDA.sol";

contract MockLogisticToLinearVRGDA is LogisticToLinearVRGDA {
    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _logisticAsymptote,
        int256 _timeScale,
        int256 _soldBySwitch,
        int256 _switchTime,
        int256 _perTimeUnit
    )
        LogisticToLinearVRGDA(
            _targetPrice,
            _priceDecayPercent,
            _logisticAsymptote,
            _timeScale,
            _soldBySwitch,
            _switchTime,
            _perTimeUnit
        )
    {}
}
