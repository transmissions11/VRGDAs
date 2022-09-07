// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadLn, unsafeDiv, unsafeWadDiv} from "../utils/SignedWadMath.sol";

import {VRGDALib, VRGDAx} from "./VRGDALib.sol";

struct LogisticVRGDAx {
    int256 logisticLimit;
    int256 timeScale;
    VRGDAx vrgda;
}

/// @title Logistic Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @author saucepoint
/// @notice VRGDA with a linear issuance curve.
library LogisticVRGDALib {
    /*//////////////////////////////////////////////////////////////
                           PRICING PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets pricing parameters for the VRGDA.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @param _maxSellable The maximum number of tokens to sell, scaled by 1e18.
    /// @param _timeScale The steepness of the logistic curve, scaled by 1e18.
    function createLogisticVRGDA(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _maxSellable,
        int256 _timeScale
    ) internal pure returns (LogisticVRGDAx memory logisticVRGDAx) {
        logisticVRGDAx = LogisticVRGDAx(
            _maxSellable + 1e18,  // add 1 wad to make the limit inclusive of _maxSellable
            _timeScale,
            VRGDALib.createVRGDA(_targetPrice, _priceDecayPercent)
        );
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    function getVRGDAPrice(LogisticVRGDAx memory self, int256 sold)
        internal
        pure
        returns (uint256)
    {
        int256 timeDelta = getTargetSaleTime(self.logisticLimit, self.timeScale, sold);
        
        return VRGDALib.getVRGDAPrice(self.vrgda.targetPrice, self.vrgda.decayConstant, timeDelta);
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(int256 logisticLimit, int256 timeScale, int256 sold) internal pure returns (int256) {
        unchecked {
            return -unsafeWadDiv(wadLn(unsafeDiv(logisticLimit * 2e18, sold + logisticLimit) - 1e18), timeScale);
        }
    }
}
