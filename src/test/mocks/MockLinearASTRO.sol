// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {LinearASTRO} from "../../LinearASTRO.sol";
import {ASTRO} from "../../ASTRO.sol";

contract MockLinearASTRO is LinearASTRO {
    constructor(
        int256 _initialPrice,
        int256 periodPriceDecrease,
        int256 _perDay
    ) 
        LinearASTRO(_perDay) 
        ASTRO(_initialPrice, periodPriceDecrease) 
    {}
}
