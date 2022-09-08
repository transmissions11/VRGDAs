// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LogisticToLinearVRGDALib, LogisticToLinearVRGDAx} from "../../src/examples/composite/LogisticToLinearVRGDALib.sol";

contract MockLogisticToLinearVRGDA {
    using LogisticToLinearVRGDALib for LogisticToLinearVRGDAx;
    LogisticToLinearVRGDAx internal logToLinearAuction;

    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _logisticAsymptote,
        int256 _timeScale,
        int256 _soldBySwitch,
        int256 _switchTime,
        int256 _perTimeUnit
    )
    {
        logToLinearAuction = LogisticToLinearVRGDALib.createLogisticToLinearVRGDA(
            _targetPrice,
            _priceDecayPercent,
            _logisticAsymptote,
            _timeScale,
            _soldBySwitch,
            _switchTime,
            _perTimeUnit
        );
    }
    function targetPrice() public view returns (int256) {
        return logToLinearAuction.vrgda.targetPrice;
    }

    function getVRGDAPrice(int256 timeSinceStart, uint256 sold) public view returns (uint256) {
        return logToLinearAuction.getVRGDAPrice(timeSinceStart, sold);
    }

    function getTargetSaleTime(int256 sold) public view returns (int256) {
        return logToLinearAuction.getTargetSaleTime(sold);
    }
}
