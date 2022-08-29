// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {LogisticNFT} from "../src/examples/LogisticNFT.sol";

contract LogisticNFTTest is DSTestPlus {
    LogisticNFT nft;

    function setUp() public {
        nft = new LogisticNFT();
    }

    function testMintNFT() public {
        nft.mint{value: 74.713094276091397864e18}();

        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(0), address(this));
    }

    function testCannotUnderpayForNFTMint() public {
        hevm.expectRevert("UNDERPAID");
        nft.mint{value: 74e18}();
    }

    function testMintAllNFT() public {
        for (uint256 i = 0; i < nft.MAX_MINTABLE(); i++) {
            nft.mint{value: address(this).balance}();
        }

        assertEq(nft.balanceOf(address(this)), nft.MAX_MINTABLE());
        for (uint256 i = 0; i < nft.MAX_MINTABLE(); i++) {
            assertEq(nft.ownerOf(i), address(this));
        }
    }

    function testCannotMintMoreThanMax() public {
        testMintAllNFT();

        hevm.expectRevert("UNDEFINED");
        nft.mint{value: address(this).balance}();
    }

    receive() external payable {}
}
