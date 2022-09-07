// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {toDaysWadUnsafe, toWadUnsafe, unsafeWadDiv, wadLn, unsafeDiv} from "../utils/SignedWadMath.sol";

import {MultiVRGDA, VRGDAx} from "../VRGDAStruct.sol";

/// @title Multi VRGDA NFT
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Example NFT sold using LinearVRGDA.
/// @dev This is an example. Do not use in production.
contract MultiNFT is ERC721, MultiVRGDA {
    /*//////////////////////////////////////////////////////////////
                              SALES STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSold; // The total number of tokens sold so far.

    uint256 public immutable startTime = block.timestamp; // When Linear VRGDA sales begin.

    uint256 public immutable publicStartTime = block.timestamp + 30 days; // When Logistic VRGDA sales begin.

    // -- VRGDA Objects --
    VRGDAx internal presaleVRGDA;
    VRGDAx internal publicVRGDA;

    // -- Linear VRGDA Params --
    int256 public perTimeUnit;  // The number of tokens to target selling in 1 full unit of time, scaled by 1e18.

    // -- Logistic VRGDA Params --
    uint256 public constant MAX_MINTABLE = 100; // Max supply. for logistic VRGDA
    int256 public immutable logisticLimit;
    int256 public immutable logisticLimitDoubled;
    int256 internal immutable timeScale;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor()
        ERC721(
            "Example Multi VRGDA NFT", // Name.
            "mVRGDA" // Symbol.
        )
    {
        // -------------------------
        // create a VRGDA to be used in presale
        // -------------------------
        presaleVRGDA = createVRGDA(69.42e18, 0.31e18);
        perTimeUnit = 2e18;  // additional state variable used for presaleVRGDA.getTargetSaleTime (this.getTargetSaleTime)

        // -----------------------------
        // create a VRGDA to used in public sale
        // note: we can reuse presaleVRGDA and overwrite the functions since they are used during different times
        // however for the sake of example, let's define two independent VRGDAs
        // -----------------------------
        publicVRGDA = createVRGDA(69.42e18, 0.31e18);
        
        // Set additional state variables used for publicVRGDA.getTargetSaleTime (this.getLogisticTargetSaleTime)
        // Add 1 wad to make the limit inclusive of _maxSellable
        logisticLimit = toWadUnsafe(MAX_MINTABLE) + 1e18;

        // Scale by 2e18 to both double it and give it 36 decimals.
        logisticLimitDoubled = logisticLimit * 2e18;
        
        // Time scale
        timeScale = 0.1e18;

        // override the target sale time function to use a logistic function
        publicVRGDA.getTargetSaleTime = getLogisticTargetSaleTime;
    }

    /*//////////////////////////////////////////////////////////////
                              VRGDA LOGIC
    //////////////////////////////////////////////////////////////*/
    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(int256 sold) public view override returns (int256) {
        return unsafeWadDiv(sold, perTimeUnit);
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getLogisticTargetSaleTime(int256 sold) public view returns (int256) {
        unchecked {
            return -unsafeWadDiv(wadLn(unsafeDiv(logisticLimitDoubled, sold + logisticLimit) - 1e18), timeScale);
        }
    }

    /*//////////////////////////////////////////////////////////////
                              MINTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint() external payable returns (uint256 mintedId) {
        unchecked {
            // conditionally set price based on time + VRGDA
            // i.e. if time < publicStartTime use presaleVRGDA else use publicVRGDA
            uint256 price;

            // Note: By using toDaysWadUnsafe(block.timestamp - startTime) we are establishing that 1 "unit of time" is 1 day.
            if (block.timestamp < publicStartTime) {
                price = getVRGDAPrice(presaleVRGDA, toDaysWadUnsafe(block.timestamp - startTime), mintedId = totalSold++);
            } else {
                price = getVRGDAPrice(publicVRGDA, toDaysWadUnsafe(block.timestamp - publicStartTime), mintedId = totalSold++);
            }

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
