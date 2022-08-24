// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {LinearVRGDA} from "../LinearVRGDA.sol";
import {toDaysWadUnsafe, toWadUnsafe} from "../utils/SignedWadMath.sol";

/// @title Linear VRGDA NFT
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @notice Example NFT sold using LinearVRGDA.
/// @dev This is an example. Do not use in production.
contract LinearNFT is ERC721, LinearVRGDA {
    /*//////////////////////////////////////////////////////////////
                              SALES STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSold; // Total number of tokens sold so far.

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor()
        ERC721(
            "Example Linear NFT", // Name.
            "LINEAR" // Symbol.
        )
        LinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        )
    {}

    /*//////////////////////////////////////////////////////////////
                              MINTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint() external payable {
        // Note: There is no maximum supply to these NFTs.

        // Note: By using toDaysWadUnsafe(block.timestamp) we are establishing that 1 "unit of time" is 1 day.
        // Ensure the caller has sent enough ETH to pay for the price of an NFT according to the VRGDA.
        uint256 price = getVRGDAPrice(toDaysWadUnsafe(block.timestamp), totalSold);

        // Refund the user any ETH they spent over the current price of the NFT.
        // No need to check msg.value >= price, it'll just revert due to underflow.
        SafeTransferLib.safeTransferETH(msg.sender, msg.value - price);

        // Mint the NFT and increment totalSold.
        _mint(msg.sender, ++totalSold);
    }

    /*//////////////////////////////////////////////////////////////
                                URI LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://example.com";
    }
}
