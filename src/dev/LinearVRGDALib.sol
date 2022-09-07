// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {unsafeWadDiv} from "../utils/SignedWadMath.sol";

import {VRGDALib, VRGDAx} from "./VRGDALib.sol";

struct LinearVRGDAx {
    int256 perTimeUnit;
    VRGDAx vrgda;
}

/// @title Linear Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @author saucepoint
/// @notice VRGDA with a linear issuance curve.
library LinearVRGDALib {
    /*//////////////////////////////////////////////////////////////
                           PRICING PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets pricing parameters for the VRGDA.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @param _perTimeUnit The number of tokens to target selling in 1 full unit of time, scaled by 1e18.
    function createLinearVRGDA(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _perTimeUnit
    ) internal pure returns (LinearVRGDAx memory linearVRGDA) {
        linearVRGDA = LinearVRGDAx(
            _perTimeUnit,
            VRGDALib.createVRGDA(_targetPrice, _priceDecayPercent)
        );
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    function getVRGDAPrice(LinearVRGDAx memory self, int256 sold)
        internal
        pure
        returns (uint256)
    {
        int256 timeDelta = getTargetSaleTime(self.perTimeUnit, sold);
        
        return VRGDALib.getVRGDAPrice(self.vrgda.targetPrice, self.vrgda.decayConstant, timeDelta);
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(int256 perTimeUnit, int256 sold) internal pure returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }
}
