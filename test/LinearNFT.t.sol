// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {LinearNFT} from "../src/examples/LinearNFT.sol";

contract LinearNFTTest is DSTestPlus {
    LinearNFT nft;

    function setUp() public {
        nft = new LinearNFT();
    }

    function testMintNFT() public {
        nft.mint{value: 83.571859212140979125e18}();

        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(0), address(this));
    }

    function testCannotUnderpayForNFTMint() public {
        hevm.expectRevert("UNDERPAID");
        nft.mint{value: 83e18}();
    }

    function testMintManyNFT() public {
        for (uint256 i = 0; i < 100; i++) {
            nft.mint{value: address(this).balance}();
        }

        assertEq(nft.balanceOf(address(this)), 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(nft.ownerOf(i), address(this));
        }
    }

    receive() external payable {}
}
