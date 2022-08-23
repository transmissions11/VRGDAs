// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {LibString} from "../utils/LibString.sol";
import {MockLinearVRGDA} from "../mocks/MockLinearVRGDA.sol";
import {toWadUnsafe} from "../../src/utils/SignedWadMath.sol";
import {console} from "forge-std/console.sol";

// Differentially fuzz VRGDA solidity implementation against python reference
contract VRGDACorrectnessTest is DSTestPlus {
    using LibString for uint256;

    // sample parameters for differential fuzzing campaign
    uint256 immutable MAX_TIMEFRAME = 356 days * 10;
    uint256 immutable MAX_SELLABLE = 10000;
    int256 immutable TARGET_PRICE = 69.42e18;
    int256 immutable PRICE_DECREASE_PERCENT = 0.31e18;
    int256 immutable PER_UNIT_TIME = 2e18;

    MockLinearVRGDA vrgda;

    function setUp() public {
        vrgda = new MockLinearVRGDA(TARGET_PRICE, PRICE_DECREASE_PERCENT, PER_UNIT_TIME);
    }

    function testFFICorrectness(uint256 timeSinceStart, uint256 numSold) public {
        // Bound fuzzer inputs to acceptable contraints.
        numSold = bound(numSold, 0, MAX_SELLABLE);
        timeSinceStart = bound(timeSinceStart, 0, MAX_TIMEFRAME);
        // Convert to wad days for convenience.
        timeSinceStart = (timeSinceStart * 10e18) / 1 days;

        // We wrap this call in a try catch because the getVRGDAPrice is expected to revert when
        // price overflows. In these cases, we continue campaign
        try vrgda.getVRGDAPrice(int256(timeSinceStart), numSold) returns (uint256 actualPrice) {
            uint256 expectedPrice = calculatePrice(
                TARGET_PRICE,
                PRICE_DECREASE_PERCENT,
                PER_UNIT_TIME,
                timeSinceStart,
                numSold
            );
            assertRelApproxEq(expectedPrice, actualPrice, 0.00001e18);
        } catch {}
    }

    // ffi call
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

        return abi.decode(hevm.ffi(inputs), (uint256));
    }
}
