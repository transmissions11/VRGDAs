// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe} from "./utils/SignedWadMath.sol";

/// @title Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @author saucepoint
/// @notice Sell tokens roughly according to an issuance schedule.
abstract contract MVRGDA {
    /*//////////////////////////////////////////////////////////////
                            VRGDA PARAMETERS
    //////////////////////////////////////////////////////////////*/
    uint256 public varCounter;

    /// @notice Target price for a token, to be scaled according to sales pace.
    /// @dev Represented as an 18 decimal fixed point number.
    // maps variable Id to target price
    mapping(uint256 => int256) public targetPrice;

    /// @dev Precomputed constant that allows us to rewrite a pow() as an exp().
    /// @dev Represented as an 18 decimal fixed point number.
    // maps variable Id to decay constant
    mapping(uint256 => int256) public decayConstant;

    /// @notice Sets target price and per time unit price decay for the VRGDA.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    function createVRGDA(int256 _targetPrice, int256 _priceDecayPercent) public {
        targetPrice[varCounter] = _targetPrice;
        int256 _decayConstant = wadLn(1e18 - _priceDecayPercent);
        require(_decayConstant < 0, "NON_NEGATIVE_DECAY_CONSTANT");
        decayConstant[varCounter] = _decayConstant;
        
        unchecked { varCounter++; }
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the price of a token according to the VRGDA formula.
    /// @param timeSinceStart Time passed since the VRGDA began, scaled by 1e18.
    /// @param sold The total number of tokens that have been sold so far.
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(uint256 varId, int256 timeSinceStart, uint256 sold) public view returns (uint256) {
        unchecked {
            // prettier-ignore
            return uint256(wadMul(targetPrice[varId], wadExp(unsafeWadMul(decayConstant[varId],
                // Theoretically calling toWadUnsafe with sold can silently overflow but under
                // any reasonable circumstance it will never be large enough. We use sold + 1 as
                // the VRGDA formula's n param represents the nth token and sold is the n-1th token.
                timeSinceStart - getTargetSaleTime(varId, toWadUnsafe(sold + 1))
            ))));
        }
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(uint256 varId, int256 sold) public view virtual returns (int256);
}
