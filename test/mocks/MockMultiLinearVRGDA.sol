// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe, unsafeWadDiv} from "../../src/utils/SignedWadMath.sol";
import {VRGDALibrary} from "../../src/lib/VRGDALibrary.sol";
import {MultiVRGDA} from "../../src/MultiVRGDA.sol";

contract MockMultiLinearVRGDA is MultiVRGDA {

    mapping(uint256 => int256) internal perTimeUnits;

    function createVRGDA(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _perTimeUnit
    ) public returns (uint256 varId) {
        varId = varCounter;
        perTimeUnits[varCounter] = _perTimeUnit;
        super.createVRGDA(_targetPrice, _priceDecayPercent);
    }

    function getTargetSaleTime(uint256 varId, int256 sold) public view override returns (int256) {
        return unsafeWadDiv(sold, perTimeUnits[varId]);
    }
}
