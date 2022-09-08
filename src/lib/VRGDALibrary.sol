// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadExp, wadLn, wadMul, unsafeWadMul, toWadUnsafe} from "solmate/utils/SignedWadMath.sol";

library VRGDALibrary {
    /// @notice Calculate the price of a token according to the VRGDA formula.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _decayConstant The constant price decays per unit of time with no sales, scaled by 1e18.
    /// @param _timeDelta Time difference between time-since-VRGDA-genesis and expected time of sale, (assumes both scaled by 1e18). I.e. timeSinceStart - targetSaleTime
    /// @return The price of a token according to VRGDA, scaled by 1e18.
    function getVRGDAPrice(int256 _targetPrice, int256 _decayConstant, int256 _timeDelta) internal pure returns (uint256) {
        unchecked {
            // prettier-ignore
            return uint256(wadMul(_targetPrice, wadExp(unsafeWadMul(_decayConstant,
                _timeDelta
            ))));
        }
    }
}