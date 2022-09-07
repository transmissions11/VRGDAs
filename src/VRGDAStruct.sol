// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe} from "./utils/SignedWadMath.sol";
import {VRGDALibrary} from "./lib/VRGDALibrary.sol";

struct VRGDAx {
    int256 targetPrice;
    int256 decayConstant;
    function (int256, int256, int256, uint256) view returns (uint256) getPrice;
    function (int256) view returns (int256) getTargetSaleTime;
}

/// @title Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @author saucepoint
/// @notice Sell tokens roughly according to an issuance schedule.
abstract contract MultiVRGDA {
    /*//////////////////////////////////////////////////////////////
                            VRGDA PARAMETERS
    //////////////////////////////////////////////////////////////*/


    /// @notice Target price for a token, to be scaled according to sales pace.
    /// @dev Represented as an 18 decimal fixed point number.

    /// @dev Precomputed constant that allows us to rewrite a pow() as an exp().
    /// @dev Represented as an 18 decimal fixed point number.

    /// @notice Sets target price and per time unit price decay for the VRGDA.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    function createVRGDA(int256 _targetPrice, int256 _priceDecayPercent) internal pure returns (VRGDAx memory vrgda) {
        int256 _decayConstant = wadLn(1e18 - _priceDecayPercent);
        require(_decayConstant < 0, "NON_NEGATIVE_DECAY_CONSTANT");
        
        vrgda = VRGDAx(
            _targetPrice,
            _decayConstant,
            getVRGDAPrice,
            getTargetSaleTime
        );
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the price of a token according to the VRGDA formula.
    /// @param timeSinceStart Time passed since the VRGDA began, scaled by 1e18.
    /// @param sold The total number of tokens that have been sold so far.
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(int256 targetPrice, int256 decayConstant, int256 timeSinceStart, uint256 sold) public view returns (uint256) {
        return VRGDALibrary.getVRGDAPrice(targetPrice, decayConstant, timeSinceStart - getTargetSaleTime(toWadUnsafe(sold + 1)));
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(int256 sold) public view virtual returns (int256);

    function getPrice(VRGDAx memory vrgda, int256 timeSinceStart, uint256 sold) internal view returns (uint256) {
        return vrgda.getPrice(vrgda.targetPrice, vrgda.decayConstant, timeSinceStart, sold);
    }
}
