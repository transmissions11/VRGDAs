// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {unsafeWadDiv} from "solmate/utils/SignedWadMath.sol";
import {BoundedVRGDA} from "../../src/BoundedVRGDA.sol";

contract MockLinearBoundedVRGDA is BoundedVRGDA {
    int256 internal immutable perTimeUnit;

    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        uint256 _min,
        int256 _perTimeUnit
    ) BoundedVRGDA(_targetPrice, _priceDecayPercent, _min) {
        perTimeUnit = _perTimeUnit;
    }

    function getTargetSaleTime(int256 sold) public view virtual override returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }
}
