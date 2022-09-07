// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {LogisticToLinearNFT} from "../src/examples/LogisticToLinearNFT.sol";

contract LogisticToLinearNFTTest is DSTestPlus {
    LogisticToLinearNFT nft;

    function setUp() public {
        nft = new LogisticToLinearNFT();
    }

    function testMintNFT() public {
        nft.mint{value: 4.231748564166457308e18}();

        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(0), address(this));
    }

    function testCannotUnderpayForNFTMint() public {
        hevm.expectRevert("UNDERPAID");
        nft.mint{value: 4e18}();
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
