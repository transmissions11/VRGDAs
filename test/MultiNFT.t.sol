// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {fromDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {MultiNFT} from "../src/examples/MultiNFT.sol";

contract MultiNFTTest is DSTestPlus {
    MultiNFT nft;

    function setUp() public {
        nft = new MultiNFT();
    }

    // -------------------------------------------------------------------
    // test the Linear VRGDA that's used during "presale" (first 30 days)
    // -------------------------------------------------------------------
    function testMintPresaleNFT() public {
        nft.mint{value: 83.571859212140979125e18}();

        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(0), address(this));
    }

    function testCannotUnderpayForPresaleNFTMint() public {
        hevm.expectRevert("UNDERPAID");
        nft.mint{value: 83e18}();
    }

    function testMintManyPresaleNFT() public {
        for (uint256 i = 0; i < 100; i++) {
            nft.mint{value: address(this).balance}();
        }

        assertEq(nft.balanceOf(address(this)), 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(nft.ownerOf(i), address(this));
        }
    }

    // -------------------------------------------------------------------------
    // test the Logistic VRGDA that's used during "public sale" (after 30 days)
    // -------------------------------------------------------------------------
    function testMintPublicNFT() public {
        // Warp to the target sale time so that the VRGDA price equals the target price.
        hevm.warp(nft.publicStartTime());

        nft.mint{value: 74.713094276091397864e18}();

        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(0), address(this));
    }

    function testCannotUnderpayForPublicNFTMint() public {
        hevm.warp(nft.publicStartTime());
        hevm.expectRevert("UNDERPAID");
        nft.mint{value: 74e18}();
    }

    function testMintAllPublicNFT() public {
        hevm.warp(nft.publicStartTime());
        for (uint256 i = 0; i < nft.MAX_MINTABLE(); i++) {
            nft.mint{value: address(this).balance}();
        }

        assertEq(nft.balanceOf(address(this)), nft.MAX_MINTABLE());
        for (uint256 i = 0; i < nft.MAX_MINTABLE(); i++) {
            assertEq(nft.ownerOf(i), address(this));
        }
    }

    function testCannotPublicMintMoreThanMax() public {
        testMintAllPublicNFT();

        hevm.expectRevert("UNDEFINED");
        nft.mint{value: address(this).balance}();
    }

    receive() external payable {}
}
