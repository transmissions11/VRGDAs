// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {wadLn, unsafeDiv, unsafeWadDiv} from "./utils/SignedWadMath.sol";

import {VRGDA} from "./VRGDA.sol";

/// @title Logistic Variable Rate Gradual Dutch Auction
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice VRGDA with a logistic issuance curve.
abstract contract LogisticVRGDA is VRGDA {
    /*//////////////////////////////////////////////////////////////
                           PRICING PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @dev The maximum number of tokens of tokens to sell + 1. We add
    /// 1 because the logistic function will never fully reach its limit.
    /// @dev Represented as an 18 decimal fixed point number.
    int256 public immutable logisticLimit;
    mapping(uint256 => int256) public logisticLimits;

    /// @dev The maximum number of tokens of tokens to sell + 1 multiplied
    /// by 2. We could compute it on the fly each time but this saves gas.
    /// @dev Represented as a 36 decimal fixed point number.
    int256 public immutable logisticLimitDoubled;
    mapping(uint256 => int256) public logisticLimitDoubles;

    /// @dev Time scale controls the steepness of the logistic curve,
    /// which affects how quickly we will reach the curve's asymptote.
    /// @dev Represented as an 18 decimal fixed point number.
    int256 internal immutable timeScale;
    mapping(uint256 => int256) public timeScales;

    /// @notice Sets pricing parameters for the VRGDA.
    /// @param _targetPrice The target price for a token if sold on pace, scaled by 1e18.
    /// @param _priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @param _maxSellable The maximum number of tokens to sell, scaled by 1e18.
    /// @param _timeScale The steepness of the logistic curve, scaled by 1e18.
    constructor(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _maxSellable,
        int256 _timeScale
    ) VRGDA(_targetPrice, _priceDecayPercent) {
        // Add 1 wad to make the limit inclusive of _maxSellable.
        logisticLimit = _maxSellable + 1e18;

        // Scale by 2e18 to both double it and give it 36 decimals.
        logisticLimitDoubled = logisticLimit * 2e18;

        timeScale = _timeScale;
    }

    function createLogisticVRGDA(
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _maxSellable,
        int256 _timeScale
    ) public returns (uint256 varId) {
        varId = varCounter;
        
        // Add 1 wad to make the limit inclusive of _maxSellable.
        logisticLimits[varCounter] = _maxSellable + 1e18;

        // Scale by 2e18 to both double it and give it 36 decimals.
        logisticLimitDoubles[varCounter] = logisticLimits[varCounter] * 2e18;

        timeScales[varCounter] = _timeScale;

        createVRGDA(_targetPrice, _priceDecayPercent);
    }

    /*//////////////////////////////////////////////////////////////
                              PRICING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(int256 sold) public view override returns (int256) {
        unchecked {
            return -unsafeWadDiv(wadLn(unsafeDiv(logisticLimitDoubled, sold + logisticLimit) - 1e18), timeScale);
        }
    }

    function getTargetSaleTime(uint256 varId, int256 sold) public view override returns (int256) {
        unchecked {
            return -unsafeWadDiv(wadLn(unsafeDiv(logisticLimitDoubles[varId], sold + logisticLimits[varId]) - 1e18), timeScales[varId]);
        }
    }
}
