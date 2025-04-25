// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter;
    mapping(uint256 tokenId => string tokenURI) private s_tokenIdToUri;

    string public constant NFT_NAME = "Dogie";
    string public constant NFT_SYMBOL = "DOG";

    constructor() ERC721(NFT_NAME, NFT_SYMBOL) {
        s_tokenCounter = 0;
    }

    function mintNFT(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }

    function getTokenCount() public view returns (uint256) {
        return s_tokenCounter;
    }
}
