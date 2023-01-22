// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {toWadUnsafe, toDaysWadUnsafe, fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

import {MockLinearBoundedVRGDA} from "./mocks/MockLinearBoundedVRGDA.sol";

uint256 constant ONE_THOUSAND_YEARS = 356 days * 1000;

contract LinearBoundedVRGDATest is DSTestPlus {
    MockLinearBoundedVRGDA vrgda;

    function setUp() public {
        vrgda = new MockLinearBoundedVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            1e18, // Min price
            2e18 // Per time unit.
        );
    }

    function testPricingBasic() public {
        // Our VRGDA targets this number of mints at the given time.
        uint256 timeDelta = 120 days;
        uint256 numMint = 239;

        hevm.warp(block.timestamp + timeDelta);

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), numMint);
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.00001e18);
    }

    function testMinPrice() public {
        uint256 timeDelta = 120 days;
        uint256 numMint = 216;

        // Warp to a sale time where the decreased VRGDA price should be less than the min.
        hevm.warp(block.timestamp + timeDelta);

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), numMint);
        assertEq(cost, uint256(vrgda.min()));
    }
}
