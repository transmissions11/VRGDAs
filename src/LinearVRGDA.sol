// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {unsafeWadDiv} from "./utils/SignedWadMath.sol";

import {VRGDA} from "./VRGDA.sol";

/// @title Linear Variable Rate Gradual Dutch Auctions.
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Abstract VRGDA with a linear issuance curve.
abstract contract LinearVRGDA is VRGDA {
    /*//////////////////////////////////////////////////////////////
                           PRICING PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @dev The total number of tokens to target selling each day.
    /// @dev Represented as an 18 decimal fixed point number.
    int256 internal immutable perDay;

    constructor(int256 _perDay) {
        perDay = _perDay;
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    function getTargetDayForNextSale(int256 sold) internal view virtual override returns (int256) {
        return unsafeWadDiv(sold, perDay);
    }
}
