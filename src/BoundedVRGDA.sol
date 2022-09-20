// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe} from "solmate/utils/SignedWadMath.sol";

import {VRGDA} from "./VRGDA.sol";

/// @title Bounded Variable Rate Gradual Dutch Auction
/// @author jacopo <jacopo@slice.so>
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Sell tokens roughly according to an issuance schedule.

abstract contract BoundedVRGDA is VRGDA {
    /*//////////////////////////////////////////////////////////////
                            VRGDA PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @dev The minimum price to be paid for a token, scaled by 1e18.
    /// @dev Represented as an 18 decimal fixed point number.
    uint256 public immutable min;

    /// @notice Sets pricing parameters for the VRGDA.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @param _min minimum price to be paid for a token, scaled by 1e18
    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        uint256 _min
    ) VRGDA(_targetPrice, _priceDecayPercent) {
        min = _min;
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the price of a token according to the VRGDA formula, bounded by min value.
    /// @param timeSinceStart Time passed since the VRGDA began, scaled by 1e18.
    /// @param sold The total number of tokens that have been sold so far.
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(int256 timeSinceStart, uint256 sold) public view virtual override returns (uint256) {
        uint256 VRGDAPrice = super.getVRGDAPrice(timeSinceStart, sold);

        return VRGDAPrice > min ? VRGDAPrice : min;
    }
}
