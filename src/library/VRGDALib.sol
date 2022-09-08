// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, unsafeWadDiv, toWadUnsafe} from "../utils/SignedWadMath.sol";

/// @title Linear Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice VRGDA with a linear issuance curve.
library VRGDALib {
    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the price of a token according to the VRGDA formula.
    /// @param timeSinceStart Time passed since the VRGDA began, scaled by 1e18.
    /// @param targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param decayConstant Precomputed constant that allows us to rewrite a pow() as an exp().
    /// @param targetSaleTime target time the tokens should be sold by, scaled by 1e18.
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(
        int256 timeSinceStart,
        int256 targetPrice,
        int256 decayConstant,
        int256 targetSaleTime
    ) public pure returns (uint256) {
        unchecked {
            // prettier-ignore
            return uint256(wadMul(targetPrice, wadExp(unsafeWadMul(decayConstant,
                // Theoretically calling toWadUnsafe with sold can silently overflow but under
                // any reasonable circumstance it will never be large enough. We use sold + 1 as
                // the VRGDA formula's n param represents the nth token and sold is the n-1th token.
                timeSinceStart - targetSaleTime
            ))));
        }
    }

    /// @dev Calculate constant that allows us to rewrite a pow() as an exp().
    /// @param priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @return The computed constant represented as an 18 decimal fixed point number.
    function computeDecayConstant(int256 priceDecayPercent) public pure returns (int256) {
        return wadLn(1e18 - priceDecayPercent);
    }
}
