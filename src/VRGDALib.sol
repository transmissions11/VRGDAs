// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe} from "solmate/utils/SignedWadMath.sol";

// TODO: rename to something better?
// VRGDAx sounds badass tho
struct VRGDAx {
    int256 targetPrice;
    int256 decayConstant;
}

/// @title Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Sell tokens roughly according to an issuance schedule.
library VRGDALib {

    /// @notice Sets target price and per time unit price decay for a VRGDA instance.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18. (18 decimal fixed point number)
    /// @param _priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18. (18 decimal fixed point number)
    function createVRGDA(int256 _targetPrice, int256 _priceDecayPercent) internal pure returns (VRGDAx memory vrgda) {
        // Precomputed constant that allows us to rewrite a pow() as an exp().
        int256 _decayConstant = wadLn(1e18 - _priceDecayPercent);
        require(_decayConstant < 0, "NON_NEGATIVE_DECAY_CONSTANT");
        
        vrgda = VRGDAx(
            _targetPrice,    // Target price for a token, to be scaled according to sales pace.
            _decayConstant  // Precomputed constant that allows us to rewrite a pow() as an exp().
        );
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the price of a token according to the VRGDA formula.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _decayConstant The constant price decays per unit of time with no sales, scaled by 1e18.
    /// @param _timeDelta Time difference between time-since-VRGDA-genesis and expected time of sale, (assumes both scaled by 1e18). I.e. timeSinceStart - targetSaleTime
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(int256 _targetPrice, int256 _decayConstant, int256 _timeDelta) internal pure returns (uint256) {
        unchecked {
            // prettier-ignore
            return uint256(wadMul(
                _targetPrice,
                wadExp(unsafeWadMul(_decayConstant, _timeDelta))
            ));
        }
    }
}
