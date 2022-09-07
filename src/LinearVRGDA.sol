// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, unsafeWadDiv, toWadUnsafe} from "./utils/SignedWadMath.sol";

/// @title Linear Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice VRGDA with a linear issuance curve.
library LinearVRGDA {
    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the price of a token according to the VRGDA formula.
    /// @param timeSinceStart Time passed since the VRGDA began, scaled by 1e18.
    /// @param targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @param perTimeUnit The number of tokens to target selling in 1 full unit of time, scaled by 1e18.
    /// @param sold The total number of tokens that have been sold so far.
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(
        int256 timeSinceStart,
        int256 targetPrice,
        int256 priceDecayPercent,
        int256 perTimeUnit,
        uint256 sold
    ) public pure returns (uint256) {
        unchecked {
            // prettier-ignore
            return uint256(wadMul(targetPrice, wadExp(unsafeWadMul(computeDecayConstant(priceDecayPercent),
                // Theoretically calling toWadUnsafe with sold can silently overflow but under
                // any reasonable circumstance it will never be large enough. We use sold + 1 as
                // the VRGDA formula's n param represents the nth token and sold is the n-1th token.
                timeSinceStart - getTargetSaleTime(toWadUnsafe(sold + 1), perTimeUnit)
            ))));
        }
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @param perTimeUnit The number of tokens to target selling in 1 full unit of time, scaled by 1e18.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(int256 sold, int256 perTimeUnit) public pure returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }

    /// @dev Calculate constant that allows us to rewrite a pow() as an exp().
    /// @param priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @return The computed constant represented as an 18 decimal fixed point number.
    function computeDecayConstant(int256 priceDecayPercent) public pure returns (int256) {
        return wadLn(1e18 - priceDecayPercent);
    }
}
