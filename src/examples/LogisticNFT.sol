// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {LogisticVRGDA} from "../LogisticVRGDA.sol";
import {toDaysWadUnsafe, toWadUnsafe} from "../utils/SignedWadMath.sol";

/// @title Logistic VRGDA NFT
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Example NFT sold using LogisticVRGDA.
/// @dev This is an example. Do not use in production.
contract LogisticNFT is ERC721, LogisticVRGDA {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_MINTABLE = 100; // Max supply.

    /*//////////////////////////////////////////////////////////////
                              SALES STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSold; // Total number of tokens sold so far.

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor()
        ERC721(
            "Example Logistic NFT", // Name.
            "LOGISTIC" // Symbol.
        )
        LogisticVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            // Maximum # mintable/sellable.
            toWadUnsafe(MAX_MINTABLE),
            0.1e18 // Time scale.
        )
    {}

    /*//////////////////////////////////////////////////////////////
                              MINTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint() external payable returns (uint256 mintedId) {
        // Note: We don't need to check totalSold < MAX_MINTABLE, because getVRGDAPrice will
        // revert if we're over the max mintable limit we set when constructing LogisticVRGDA.

        // Note: By using toDaysWadUnsafe(block.timestamp) we are establishing that 1 "unit of time" is 1 day.
        // Ensure the caller has sent enough ETH to pay for the price of an NFT according to the VRGDA.
        uint256 price = getVRGDAPrice(toDaysWadUnsafe(block.timestamp), mintedId = totalSold++);

        _mint(msg.sender, mintedId); // Mint the NFT using mintedId.

        // Note: We do this at the end to avoid creating a reentrancy vector.
        // Refund the user any ETH they spent over the current price of the NFT.
        // No need to check msg.value >= price, it'll just revert due to underflow.
        SafeTransferLib.safeTransferETH(msg.sender, msg.value - price);
    }

    /*//////////////////////////////////////////////////////////////
                                URI LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://example.com";
    }
}
