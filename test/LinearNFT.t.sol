// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {LinearNFT} from "../src/examples/LinearNFT.sol";

bytes constant UNDERFLOW = abi.encodeWithSignature("Panic(uint256)", 0x11);

contract LinearVRGDATest is DSTestPlus {
    LinearNFT nft;

    function setUp() public {
        nft = new LinearNFT();
    }

    function testMintNFT() public {
        nft.mint{value: 83.571504e18}();

        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(1), address(this));
    }

    function testCannotUnderpayForNFTMint() public {
        hevm.expectRevert(UNDERFLOW);
        nft.mint{value: 82.571504e18}();
    }

    function testMintManyNFT() public {
        for (uint256 i = 0; i < 100; i++) {
            nft.mint{value: address(this).balance}();
        }

        assertEq(nft.balanceOf(address(this)), 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(nft.ownerOf(i + 1), address(this));
        }
    }

    receive() external payable {}
}
