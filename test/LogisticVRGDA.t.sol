// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {toWadUnsafe, toDaysWadUnsafe, fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";

import {MockLogisticVRGDA} from "./mocks/MockLogisticVRGDA.sol";

uint256 constant ONE_THOUSAND_YEARS = 356 days * 1000;

uint256 constant MAX_SELLABLE = 6392;

contract LogisticVRGDATest is DSTestPlus {
    MockLogisticVRGDA vrgda;

    function setUp() public {
        vrgda = new MockLogisticVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            toWadUnsafe(MAX_SELLABLE), // Max sellable.
            0.0023e18 // Time scale.
        );
    }

    function testTargetPrice() public {
        // Warp to the target sale time so that the VRGDA price equals the target price.
        hevm.warp(block.timestamp + fromDaysWadUnsafe(vrgda.getTargetSaleTime(1e18)));

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), 0);
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.0000001e18);
    }

    function testPricingBasic() public {
        // Our VRGDA targets this number of mints at the given time.
        uint256 timeDelta = 120 days;
        uint256 numMint = 876;

        hevm.warp(block.timestamp + timeDelta);

        uint256 cost = vrgda.getVRGDAPrice(toDaysWadUnsafe(block.timestamp), numMint);

        // Equal within 2 percent since num mint is rounded from true decimal amount.
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.02e18);
    }

    function testGetTargetSaleTimeDoesNotRevertEarly() public view {
        vrgda.getTargetSaleTime(toWadUnsafe(MAX_SELLABLE));
    }

    function testGetTargetSaleTimeRevertsWhenExpected() public {
        int256 maxMintablePlusOne = toWadUnsafe(MAX_SELLABLE + 1);

        hevm.expectRevert("UNDEFINED");
        vrgda.getTargetSaleTime(maxMintablePlusOne);
    }

    function testNoOverflowForMostTokens(uint256 timeSinceStart, uint256 sold) public {
        vrgda.getVRGDAPrice(toDaysWadUnsafe(bound(timeSinceStart, 0 days, ONE_THOUSAND_YEARS)), bound(sold, 0, 1730));
    }

    function testNoOverflowForAllTokens(uint256 timeSinceStart, uint256 sold) public {
        vrgda.getVRGDAPrice(
            toDaysWadUnsafe(bound(timeSinceStart, 3870 days, ONE_THOUSAND_YEARS)),
            bound(sold, 0, 6391)
        );
    }

    function testFailOverflowForBeyondLimitTokens(uint256 timeSinceStart, uint256 sold) public {
        vrgda.getVRGDAPrice(
            toDaysWadUnsafe(bound(timeSinceStart, 0 days, ONE_THOUSAND_YEARS)),
            bound(sold, 6392, type(uint128).max)
        );
    }

    function testAlwaysTargetPriceInRightConditions(uint256 sold) public {
        sold = bound(sold, 0, MAX_SELLABLE - 1);

        assertRelApproxEq(
            vrgda.getVRGDAPrice(vrgda.getTargetSaleTime(toWadUnsafe(sold + 1)), sold),
            uint256(vrgda.targetPrice()),
            0.00001e18
        );
    }
}
