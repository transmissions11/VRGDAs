// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {toWadUnsafe, toDaysWadUnsafe, fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

import {MockLogisticToLinearVRGDA} from "./mocks/MockLogisticToLinearVRGDA.sol";

uint256 constant ONE_THOUSAND_YEARS = 356 days * 1000;

int256 constant SWITCH_DAY_WAD = 233e18;

int256 constant SOLD_BY_SWITCH_WAD = 8336.760939794622713006e18;

contract LogisticToLinearVRGDATest is DSTestPlus {
    MockLogisticToLinearVRGDA vrgda;

    function setUp() public {
        vrgda = new MockLogisticToLinearVRGDA(
            4.2069e18, // Target price.
            0.31e18, // Price decay percent.
            9000e18, // Logistic asymptote.
            0.014e18, // Logistic time scale.
            SOLD_BY_SWITCH_WAD, // Sold by switch.
            SWITCH_DAY_WAD, // Target switch day.
            9e18 // Tokens to target per day.
        );
    }

    function testTargetPrice() public {
        // Warp to the target sale time so that the VRGDA price equals the target price.
        hevm.warp(block.timestamp + fromDaysWadUnsafe(vrgda.getTargetSaleTime(1e18)));

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), 0);
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.00001e18);
    }

    function testSwitchSmoothness() public {
        uint256 switchTokenSaleTime = uint256(vrgda.getTargetSaleTime(8337e18) - vrgda.getTargetSaleTime(8336e18));

        assertRelApproxEq(
            uint256(vrgda.getTargetSaleTime(8336e18) - vrgda.getTargetSaleTime(8335e18)),
            switchTokenSaleTime,
            0.0005e18
        );

        assertRelApproxEq(
            switchTokenSaleTime,
            uint256(vrgda.getTargetSaleTime(8338e18) - vrgda.getTargetSaleTime(8337e18)),
            0.005e18
        );
    }

    function testPricingBasic() public {
        // Our VRGDA targets this number of mints at the given time.
        uint256 timeDelta = 60 days;
        uint256 numMint = 3572;

        hevm.warp(block.timestamp + timeDelta);

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), numMint);
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.002e18);
    }

    function testAlwaysTargetPriceInRightConditions(uint256 sold) public {
        sold = bound(sold, 0, type(uint128).max);

        assertRelApproxEq(
            vrgda.getVRGDAPrice(vrgda.getTargetSaleTime(toWadUnsafe(sold + 1)), sold),
            uint256(vrgda.targetPrice()),
            0.00001e18
        );
    }
}
