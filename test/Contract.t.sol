// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {Contract} from "../src/dev/Contract.sol";

contract LinearNFTTest is DSTestPlus {
    Contract c;

    function setUp() public {
        c = new Contract();
    }

    function rng(uint256 a, uint256 b) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(a, b))) % 100;
    }

    function testGas() public {
        uint256 price = c.getPriceLinear();
        c.buyLinear{value: price}(1);

        price = c.getPriceLogistic();
        c.buyLogistic{value: price}(1);

        uint256 amount;
        for (uint256 i = 0; i < 100; i++) {
            price = c.getPriceLinear();
            amount = rng(i, price);
            c.buyLinear{value: (price * amount)}(amount);
            hevm.warp(block.timestamp + rng(i, block.timestamp));
        }

        for (uint256 i = 0; i < 100; i++) {
            price = c.getPriceLogistic();
            amount = rng(i, price);
            c.buyLogistic{value: (price * amount)}(amount);
            hevm.warp(block.timestamp + rng(i, block.timestamp));
        }
    }
}
