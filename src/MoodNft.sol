// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__UnauthorizedMoodFlip();
    enum Mood {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    string private s_happySvgImageUri;
    string private s_sadSvgImageUri;

    mapping(uint256 tokenId => Mood) private s_tokenIdToMood;

    string private constant NFT_NAME = "Mood Nft";
    string private constant NFT_SYMBOL = "MN";

    constructor(string memory sadSvgImageUri, string memory happySvgImageUri) ERC721(NFT_NAME, NFT_SYMBOL) {
        s_tokenCounter = 0;
        s_happySvgImageUri = happySvgImageUri;
        s_sadSvgImageUri = sadSvgImageUri;
    }

    modifier onlyOwner(uint256 tokenId){
        address owner = ownerOf(tokenId);
        if(!_isAuthorized(owner, msg.sender, tokenId)){
            revert MoodNft__UnauthorizedMoodFlip();
        }
        _;
    }

    function mintNft() external {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) external onlyOwner(tokenId){
        if(s_tokenIdToMood[tokenId] == Mood.HAPPY){
            s_tokenIdToMood[tokenId] = Mood.SAD;
        }
        else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageUri = s_happySvgImageUri;
        } else {
            imageUri = s_sadSvgImageUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            '", "description" : "An Nft that reflects the owners Mood", "attributes": "[{"trait_type": "moodiness","value": 100}]", "image": "',
                            imageUri,
                            '" }'
                        )
                    )
                )
            )
        );
    }
}
