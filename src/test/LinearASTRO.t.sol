// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {MockLinearASTRO} from "./mocks/MockLinearASTRO.sol";
import {Utilities} from "./utils/Utilities.sol";
import {wadExp, wadLn, wadMul, unsafeWadMul, unsafeWadDiv, toWadUnsafe} from "../utils/SignedWadMath.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

contract TestContract is Test {
    using Strings for uint256;

    Utilities internal utils;
    MockLinearASTRO internal astro;

    // initialPrice = 100
    int256 internal initialPrice = toWadUnsafe(100);
    // periodPriceDecrease = 20%
    int256 internal periodPriceDecrease = unsafeWadDiv(1, 5);
    // sellPerDay
    int256 internal perDay = toWadUnsafe(2);

    // ffi test parameters
    // number of days to check
    uint256 constant max_days_since_start = 5;
    // step size (fraction of day); 1 means no fractional days
    uint256 constant step_day_fraction = 2;
    // multiple of per day target to check up to
    uint256 constant target_quantity_multiple = 3;
    // create range of timestamps
    uint256 constant size = max_days_since_start * step_day_fraction;

    function setUp() public {
        astro = new MockLinearASTRO(initialPrice, periodPriceDecrease, perDay);
    }

    function testInitialPrice() public {
        //initialPrice should be price scale
        uint256 initial = uint256(initialPrice);
        uint256 purchasePrice = astro.getPrice(1 days, uint256(perDay / 1e18));
        console.log("initial price: ", initial);
        console.log("purchas price: ", purchasePrice);
        utils.assertApproxEqual(initial, purchasePrice, 100);
    }

    function testDayOneMulti() public {
        uint256 timeSinceStart = 1 days;
        uint8[3] memory sold = [1, 2, 3];
        for (uint256 i = 0; i < sold.length; i++) {
            uint256 price = astro.getPrice(timeSinceStart, sold[i]);
            console.log("sold: ", sold[i]);
            console.log("price: ", price);
            console.log("---------");
        }
    }

    function testFFICorrectnessOne() public {
        uint256[size] memory timesteps;
        for (uint256 i = 0; i < timesteps.length; i++) {
            timesteps[i] = (1 days * i) / step_day_fraction;
        }

        // max quantity to check at each timestamp
        uint256 max_quantity = target_quantity_multiple * uint256(perDay);

        for (uint256 i = 0; i < timesteps.length; i++) {
            for (uint256 k = 0; k <= max_quantity; k++) {
                checkPriceWithParameters(initialPrice, periodPriceDecrease, perDay, timesteps[i], k);
            }
        }
    }

    //call out to python script for price computation
    function calculatePrice(
        int256 _initialPrice,
        int256 _periodPriceDecrease,
        int256 _perDay,
        uint256 _timeSinceStart,
        uint256 _sold
    ) private returns (uint256) {
        string[] memory inputs = new string[](15);
        inputs[0] = "python3";
        inputs[1] = "analysis/get_price.py";
        inputs[2] = "linear";
        inputs[3] = "--initial_price";
        inputs[4] = uint256(_initialPrice).toString();
        inputs[5] = "--period_price_decrease";
        inputs[6] = uint256(_periodPriceDecrease).toString();
        inputs[7] = "--per_day";
        inputs[8] = uint256(_perDay).toString();
        inputs[9] = "--time_since_start";
        inputs[10] = _timeSinceStart.toString();
        inputs[13] = "--sold";
        inputs[14] = _sold.toString();
        bytes memory res = vm.ffi(inputs);
        uint256 price = abi.decode(res, (uint256));
        return price;
    }

    //parametrized test helper
    function checkPriceWithParameters(
        int256 _initialPrice,
        int256 _periodPriceDecrease,
        int256 _perDay,
        uint256 _timeSinceStart,
        uint256 _sold
    ) private {
        MockLinearASTRO _astro = new MockLinearASTRO(_initialPrice, _periodPriceDecrease, _perDay);

        //calculate actual price from gda
        uint256 actualPrice = _astro.getPrice(_timeSinceStart, _sold);

        //calculate expected price from python script
        uint256 expectedPrice = calculatePrice(_initialPrice, _periodPriceDecrease, _perDay, _timeSinceStart, _sold);

        //equal within 0.1%
        utils.assertApproxEqual(actualPrice, expectedPrice, 1);
    }
}
