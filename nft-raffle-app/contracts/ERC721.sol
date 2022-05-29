// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract samplecontractERC721 {
    function approveAll(address to, address nftTokenContract) public {
        // approve can only be called by the owner of the NFT
        IERC721(nftTokenContract).setApprovalForAll(to, true);
    }
}
