// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {toDaysWadUnsafe, toWadUnsafe, unsafeWadDiv, wadLn, unsafeDiv} from "../utils/SignedWadMath.sol";

import {LinearVRGDALib, LinearVRGDAx} from "../LinearVRGDALib.sol";
import {LogisticVRGDALib, LogisticVRGDAx} from "../LogisticVRGDALib.sol";

/// @title Multi VRGDA NFT
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Example NFT sold using BOTH Linear VRGDA and Logistic VRGDA.
/// @dev This is an example. Do not use in production.
contract MultiNFT is ERC721 {
    using LinearVRGDALib for LinearVRGDAx;
    using LogisticVRGDALib for LogisticVRGDAx;
    /*//////////////////////////////////////////////////////////////
                              SALES STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSold; // The total number of tokens sold so far.

    uint256 public immutable startTime = block.timestamp; // When Linear VRGDA sales begin.

    uint256 public immutable publicStartTime = block.timestamp + 30 days; // When Logistic VRGDA sales begin.

    // -- VRGDA Objects --
    LinearVRGDAx internal presaleVRGDA;
    LogisticVRGDAx internal publicVRGDA;

    // -- Linear VRGDA Params --
    int256 public perTimeUnit;  // The number of tokens to target selling in 1 full unit of time, scaled by 1e18.

    // -- Logistic VRGDA Params --
    uint256 public constant MAX_MINTABLE = 100; // Max supply. for logistic VRGDA

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
        presaleVRGDA = LinearVRGDALib.createLinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18  // 2 units sold per unit of time
        );

        // -----------------------------
        // create a VRGDA to used in public sale
        // note: we can reuse presaleVRGDA and overwrite the .getTargetSaleTime since
        // they are used during different times. However for the sake of example, let's define two independent VRGDAs
        // -----------------------------
        publicVRGDA = LogisticVRGDALib.createLogisticVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            // Maximum # mintable/sellable.
            toWadUnsafe(MAX_MINTABLE),
            0.1e18 // Time scale.
        );
    }

    /*//////////////////////////////////////////////////////////////
                              MINTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint() external payable returns (uint256 mintedId) {
        unchecked {
            // mintedId = totalSold++;
            // conditionally set price based on time + VRGDA
            // i.e. if time < publicStartTime use presaleVRGDA else use publicVRGDA
            uint256 price;

            if (block.timestamp < publicStartTime) {
                // Note: By using toDaysWadUnsafe(block.timestamp - startTime) we are establishing that 1 "unit of time" is 1 day.
                price = presaleVRGDA.getVRGDAPrice(toDaysWadUnsafe(block.timestamp - startTime), mintedId = totalSold++);
            } else {
                price = publicVRGDA.getVRGDAPrice(toDaysWadUnsafe(block.timestamp - publicStartTime), mintedId = totalSold++);
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
