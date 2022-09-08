// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LogisticVRGDALib, LogisticVRGDAx} from "../../src/LogisticVRGDALib.sol";

contract MockLogisticVRGDA {
    using LogisticVRGDALib for LogisticVRGDAx;
    LogisticVRGDAx internal logAuction;
    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _maxSellable,
        int256 _timeScale
    ) {
        logAuction = LogisticVRGDALib.createLogisticVRGDA(
            _targetPrice,
            _priceDecayPercent,
            _maxSellable,
            _timeScale
        );
    }

    function targetPrice() public view returns (int256) {
        return logAuction.vrgda.targetPrice;
    }

    function getVRGDAPrice(int256 timeSinceStart, uint256 sold) public view returns (uint256) {
        return logAuction.getVRGDAPrice(timeSinceStart, sold);
    }

    function getTargetSaleTime(int256 sold) public view returns (int256) {
        return LogisticVRGDALib.getTargetSaleTime(logAuction.logisticLimit, logAuction.timeScale, sold);
    }
}
