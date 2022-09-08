// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {MockLinearVRGDA} from "../mocks/MockLinearVRGDA.sol";
import {toWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";

contract LinearVRGDACorrectnessTest is DSTestPlus {
    Vm public constant vm = Vm(address(hevm));

    // Sample parameters for differential fuzzing campaign.
    uint256 immutable MAX_TIMEFRAME = 356 days * 10;
    uint256 immutable MAX_SELLABLE = 10000;
    int256 immutable TARGET_PRICE = 69.42e18;
    int256 immutable PRICE_DECREASE_PERCENT = 0.31e18;
    int256 immutable PER_UNIT_TIME = 2e18;

    MockLinearVRGDA vrgda;

    function setUp() public {
        vrgda = new MockLinearVRGDA(TARGET_PRICE, PRICE_DECREASE_PERCENT, PER_UNIT_TIME);
    }

    function testFFICorrectness() public {
        // 10 days in wads.
        uint256 timeSinceStart = 10e18;

        // Number sold, slightly ahead of schedule.
        uint256 numSold = 25;

        uint256 actualPrice = vrgda.getVRGDAPrice(int256(timeSinceStart), numSold);
        uint256 expectedPrice = calculatePrice(
            TARGET_PRICE,
            PRICE_DECREASE_PERCENT,
            PER_UNIT_TIME,
            timeSinceStart,
            numSold
        );

        console.log("actual price", actualPrice);
        console.log("expected price", expectedPrice);

        // Check approximate equality.
        assertRelApproxEq(expectedPrice, actualPrice, 0.00001e18);

        // Sanity check that prices are greater than zero.
        assertGt(actualPrice, 0);
    }

    // fuzz to test correctness against multiple inputs
    function testFFICorrectnessFuzz(uint256 timeSinceStart, uint256 numSold) public {
        // Bound fuzzer inputs to acceptable ranges.
        numSold = bound(numSold, 0, MAX_SELLABLE);
        timeSinceStart = bound(timeSinceStart, 0, MAX_TIMEFRAME);

        // Convert to wad days for convenience.
        timeSinceStart = (timeSinceStart * 1e18) / 1 days;

        // We wrap this call in a try catch because the getVRGDAPrice is expected to
        // revert for degenerate cases. When this happens, we just continue campaign.
        try vrgda.getVRGDAPrice(int256(timeSinceStart), numSold) returns (uint256 actualPrice) {
            uint256 expectedPrice = calculatePrice(
                TARGET_PRICE,
                PRICE_DECREASE_PERCENT,
                PER_UNIT_TIME,
                timeSinceStart,
                numSold
            );

            if (expectedPrice < 0.0000001e18) return; // For really small prices, we expect divergence, so we skip.

            assertRelApproxEq(expectedPrice, actualPrice, 0.00001e18);
        } catch {}
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
        inputs[1] = "test/correctness/python/compute_price.py";
        inputs[2] = "linear";
        inputs[3] = "--time_since_start";
        inputs[4] = vm.toString(_timeSinceStart);
        inputs[5] = "--num_sold";
        inputs[6] = vm.toString(_numSold);
        inputs[7] = "--target_price";
        inputs[8] = vm.toString(uint256(_targetPrice));
        inputs[9] = "--price_decrease_percent";
        inputs[10] = vm.toString(uint256(_priceDecreasePercent));
        inputs[11] = "--per_time_unit";
        inputs[12] = vm.toString(uint256(_perUnitTime));

        return abi.decode(vm.ffi(inputs), (uint256));
    }
}
