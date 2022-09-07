// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {toDaysWadUnsafe, toWadUnsafe} from "../utils/SignedWadMath.sol";

import {LogisticVRGDA} from "../LogisticVRGDA.sol";

/// @title Logistic VRGDA NFT
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Example NFT sold using LogisticVRGDA.
/// @dev This is an example. Do not use in production.
contract LogisticNFT is ERC721 {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_MINTABLE = 100; // Max supply.

    /*//////////////////////////////////////////////////////////////
                              SALES STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSold; // The total number of tokens sold so far.

    uint256 public startTime = block.timestamp; // When VRGDA sales begun.

    /*//////////////////////////////////////////////////////////////
                           PRICING PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Target price for a token, to be scaled according to sales pace.
    /// @dev Represented as an 18 decimal fixed point number.
    int256 public immutable targetPrice;

    /// @dev The steepness of the logistic curve, scaled by 1e18.
    int256 internal immutable timeScale;

    /// @dev The percent price decays per unit of time with no sales, scaled by 1e18
    int256 internal immutable priceDecayPercent;

    /// @notice The maximum number of tokens to sell, scaled by 1e18.
    /// @dev Used to calculate logisticLimit and logisticLimitDoubled.
    int256 public immutable maxSellable;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor()
        ERC721(
            "Example Logistic NFT", // Name.
            "LOGISTIC" // Symbol.
        )
    {
        targetPrice = 69.42e18;
        priceDecayPercent = 0.31e18;
        maxSellable = toWadUnsafe(MAX_MINTABLE);
        timeScale = 0.1e18;
    }

    /*//////////////////////////////////////////////////////////////
                              MINTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint() external payable returns (uint256 mintedId) {
        // Note: We don't need to check totalSold < MAX_MINTABLE, because getVRGDAPrice will
        // revert if we're over the max mintable limit we set when constructing LogisticVRGDA.

        unchecked {
            // Note: By using toDaysWadUnsafe(block.timestamp - startTime) we are establishing that 1 "unit of time" is 1 day.
            uint256 price = LogisticVRGDA.getVRGDAPrice(
                toDaysWadUnsafe(block.timestamp - startTime),
                targetPrice,
                priceDecayPercent,
                maxSellable,
                timeScale,
                mintedId = totalSold++
            );

            require(msg.value >= price, "UNDERPAID"); // Don't allow underpaying.

            _mint(msg.sender, mintedId); // Mint the NFT using mintedId.

            // Note: We do this at the end to avoid creating a reentrancy vector.
            // Refund the user any ETH they spent over the current price of the NFT.
            // Unchecked is safe here because we validate msg.value >= price above.
            SafeTransferLib.safeTransferETH(msg.sender, msg.value - price);
        }
    }

    /*//////////////////////////////////////////////////////////////
                                URI LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://example.com";
    }
}
