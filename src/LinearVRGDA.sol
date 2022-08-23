// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {unsafeWadDiv} from "./utils/SignedWadMath.sol";

import {VRGDA} from "./VRGDA.sol";

/// @title Linear Variable Rate Gradual Dutch Auctions
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice VRGDA with a linear issuance curve.
contract LinearVRGDA is VRGDA {
    /*//////////////////////////////////////////////////////////////
                           PRICING PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @dev The total number of tokens to target selling each day.
    /// @dev Represented as an 18 decimal fixed point number.
    int256 internal immutable perDay;

    /// @notice Sets pricing parameters for the VRGDA.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _priceDecreasePercent Percent price decrease per unit of time, scaled by 1e18.
    /// @param _perDay The total number of tokens to target selling each day, scaled by 1e18.
    constructor(
        int256 _targetPrice,
        int256 _priceDecreasePercent,
        int256 _perDay
    ) VRGDA(_targetPrice, _priceDecreasePercent) {
        perDay = _perDay;
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Given a number of tokens sold, return the target day that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale day for.
    /// @return The target day the tokens should be sold by, scaled by 1e18, where the day is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleDay(int256 sold) public view virtual override returns (int256) {
        return unsafeWadDiv(sold, perDay);
    }
}
