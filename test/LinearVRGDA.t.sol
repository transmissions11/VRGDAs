// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {toWadUnsafe, toDaysWadUnsafe, fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

import {MockLinearVRGDA} from "./mocks/MockLinearVRGDA.sol";

uint256 constant ONE_THOUSAND_YEARS = 356 days * 1000;

contract LinearVRGDATest is DSTestPlus {
    MockLinearVRGDA vrgda;

    function setUp() public {
        vrgda = new MockLinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        );
    }

    function testTargetPrice() public {
        // Warp to the target sale time so that the VRGDA price equals the target price.
        hevm.warp(block.timestamp + fromDaysWadUnsafe(vrgda.getTargetSaleTime(1e18)));

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), 0);
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.00001e18);
    }

    function testPricingBasic() public {
        // Our VRGDA targets this number of mints at the given time.
        uint256 timeDelta = 120 days;
        uint256 numMint = 239;

        hevm.warp(block.timestamp + timeDelta);

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), numMint);
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.00001e18);
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
