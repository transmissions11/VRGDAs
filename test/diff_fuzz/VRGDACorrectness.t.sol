// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {LibString} from "../utils/LibString.sol";
import {MockLinearVRGDA} from "../mocks/MockLinearVRGDA.sol";
import {console} from "forge-std/console.sol";


uint256 constant TWENTY_YEARS = 356 days * 20;

uint256 constant MAX_SELLABLE = 6392;

int256 immutable TARGET_PRICE = 69.42e18;

int256 immutable PRICE_DECREASE_PERCENT = 0.31e18;

int256 immutable PER_UNIT_TIME = 0.0023e18;


contract VRGDACorrectnessTest is DSTestPlus {
    using LibString for uint256;

    MockLinearVRGDA vrgda;

    function setUp() public {
        vrgda = new MockLinearVRGDA(
            TARGET_PRICE, // Target price.
            PRICE_DECREASE_PERCENT, // Price decrease percent.
            PER_UNIT_TIME // Per time unit.
        );
    }

    function testFFICorrectness() public {
    ///function testFFICorrectness(uint256 timeSinceStart, uint256 numSold) public {
        // Limit num sold to max mint.
        // numSold = bound(numSold, 0, MAX_MINTABLE);
        uint256 numSold = 0;

        // Limit mint time to 20 years.
        // timeSinceStart = bound(timeSinceStart, 0, TWENTY_YEARS);
        uint256 timeSinceStart = 1 days;

        uint256 expectedPrice = calculatePrice(
                TARGET_PRICE,
                PRICE_DECREASE_PERCENT,
                PER_UNIT_TIME,
                numSold,
                timeSinceStart
        );

        console.log("AAA");
        console.log(expectedPrice);

        // uint256 actualPrice;

        // console.log()


    }

    function calculatePrice(
        int256 _targetPrice,
        int256 _priceDecreasePercent,
        int256 _perUnitTime,
        uint256 _timeSinceStart,
        uint256 _numSold
    ) private returns (uint256) {
        string[] memory inputs = new string[](13);
        inputs[0] = "python3";
        inputs[1] = "test/diff_fuzz/python/compute_price.py";
        inputs[2] = "linear";
        inputs[3] = "--time_since_start";
        inputs[4] = _timeSinceStart.toString();
        inputs[5] = "--num_sold";
        inputs[6] = _numSold.toString();
        inputs[7] = "--target_price";
        inputs[8] = uint256(_targetPrice).toString();
        inputs[9] = "--price_decrease_percent";
        inputs[10] = uint256(_priceDecreasePercent).toString();
        inputs[11] = "--per_time_unit";
        inputs[12] = uint256(_perUnitTime).toString();

        return abi.decode(vm.ffi(inputs), (uint256));
    }
}
