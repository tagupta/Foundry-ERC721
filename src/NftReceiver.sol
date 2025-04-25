// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract NftReceiver is IERC721Receiver {
    struct ReceivedNft {
        address collection;
        uint256 tokenId;
        address sender;
    }

    mapping(uint256 transferCount => ReceivedNft) private s_receivedNfts;
    uint256 private s_transferCount;

    event NFTReceived(
        address indexed operator, address indexed from, uint256 indexed tokenId, bytes data, uint256 transferId
    );

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        s_receivedNfts[s_transferCount] = ReceivedNft({collection: msg.sender, tokenId: tokenId, sender: from});
        emit NFTReceived(operator, from, tokenId, data, s_transferCount);
        s_transferCount++;

        return this.onERC721Received.selector;
    }

    /**
     * @dev allows owners to transfer out NFTs from this contract
     */
    function transferNft(address collection, uint256 tokenId, address recipient) external {
        IERC721(collection).safeTransferFrom(address(this), recipient, tokenId);
    }

    /**
     * @dev Checks if contract can receive ERC721 tokens
     */
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId || interfaceId == type(IERC165).interfaceId; // ERC165 interface ID
    }
}
