// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, unsafeWadDiv, toWadUnsafe, unsafeDiv} from "../utils/SignedWadMath.sol";

import {VRGDALib} from "./VRGDALib.sol";

/// @title Linear Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice VRGDA with a linear issuance curve.
library LogisticVRGDALib {
    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the price of a token according to the VRGDA formula.
    /// @param timeSinceStart Time passed since the VRGDA began, scaled by 1e18.
    /// @param targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param decayConstant The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(
        int256 timeSinceStart,
        int256 targetPrice,
        int256 decayConstant,
        int256 targetSaleTime
    ) public pure returns (uint256) {
        return VRGDALib.getVRGDAPrice(timeSinceStart, targetPrice, decayConstant, targetSaleTime);
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(
        int256 logisticLimitDoubled,
        int256 logisticLimit,
        int256 timeScale,
        int256 sold
    ) public pure returns (int256) {
        unchecked {
            return -unsafeWadDiv(wadLn(unsafeDiv(logisticLimitDoubled, sold + logisticLimit) - 1e18), timeScale);
        }
    }
}
