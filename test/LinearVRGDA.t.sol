// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {toWadUnsafe, toDaysWadUnsafe, fromDaysWadUnsafe} from "../src/utils/SignedWadMath.sol";

import {MockLinearVRGDA} from "./mocks/MockLinearVRGDA.sol";

uint256 constant ONE_THOUSAND_YEARS = 356 days * 1000;

uint256 constant MAX_SELLABLE = 6392;

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
        // Our VRGDA targets this number of mints at given time.
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

    function testCreateVRGDA() public {
        // Warp to the target sale time so that the VRGDA price equals the target price.
        hevm.warp(block.timestamp + fromDaysWadUnsafe(vrgda.getTargetSaleTime(1e18)));
        
        uint256 varId = vrgda.createLinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        );
        // first created VRGDA will have id 0
        assertEq(varId, 0);

        uint256 cost = vrgda.getVRGDAPrice(varId, toDaysWadUnsafe(block.timestamp), 0);
        assertRelApproxEq(cost, uint256(vrgda.targetPrices(varId)), 0.00001e18);
    }

    function testPricingBasicCreatedVar() public {
        // create an unused VRGDA variable
        vrgda.createLinearVRGDA(0, 1, 0);
        
        uint256 varId = vrgda.createLinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        );

        assertEq(varId, 1); // second VRGDA variable created 

        // Our VRGDA targets this number of mints at given time.
        uint256 timeDelta = 120 days;
        uint256 numMint = 239;

        hevm.warp(block.timestamp + timeDelta);

        uint256 cost = vrgda.getVRGDAPrice(varId, toDaysWadUnsafe(block.timestamp), numMint);
        assertRelApproxEq(cost, uint256(vrgda.targetPrice()), 0.00001e18);
    }

    function testAlwaysTargetPriceInRightConditionsCreated(uint256 sold) public {
        uint256 varId = vrgda.createLinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        );
        // first created VRGDA will have id 0
        assertEq(varId, 0);
        sold = bound(sold, 0, type(uint128).max);

        assertRelApproxEq(
            vrgda.getVRGDAPrice(varId, vrgda.getTargetSaleTime(varId, toWadUnsafe(sold + 1)), sold),
            uint256(vrgda.targetPrices(varId)),
            0.00001e18
        );
    }
}
