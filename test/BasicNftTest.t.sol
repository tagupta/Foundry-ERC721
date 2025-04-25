// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNft} from "script/DeployBasicNft.s.sol";
import {BasicNft} from "src/BasicNft.sol";
import {IERC721Errors} from '@openzeppelin/contracts/interfaces/draft-IERC6093.sol';

contract MockContract {
    constructor(){
    }
}
contract BasicNftTest is Test {

    DeployBasicNft deployer;
    BasicNft basicNft;
    address public USER = makeAddr('user');
    address public STRANGER = makeAddr('stranger');
    string public constant PUG = "ipfs://QmcX8ncdt8WTDfzzrhiQ1R8fpw42jAz4oTbZ2rR9YkNgoQ/?filename=0-PUG.json";
    string public constant SHIBA = "ipfs://QmfADiCkoCFjXLvZJax6EGru1D9YJZ7gTxmyTt8SLvBMr7/?filename=0-SHIBA.json";

    function setUp() external {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }
    /*//////////////////////////////////////////////////////////////
                               BASIC TEST
    //////////////////////////////////////////////////////////////*/

    function test_NftMetadata() external view {
        bytes32 nftName = keccak256(bytes(basicNft.NFT_NAME()));
        bytes32 name = keccak256(bytes(basicNft.name()));
        assertEq(nftName, name);

        bytes32 nftSymbol = keccak256(bytes(basicNft.NFT_SYMBOL()));
        bytes32 symbol = keccak256(bytes(basicNft.symbol()));
        assertEq(nftSymbol, symbol);

    }

    function test_InitialCounterValueIsZero() view external {
        uint initalTokenCount = basicNft.getTokenCount();
        assertEq(initalTokenCount, 0);
    }

    /*//////////////////////////////////////////////////////////////
                              MINTING TEST
    //////////////////////////////////////////////////////////////*/
    modifier mintNftUser() {
        vm.prank(USER);
        basicNft.mintNFT(PUG);
        _;
    }

    function testMintANft() external mintNftUser {
        assertEq(USER, basicNft.ownerOf(0));
        assertEq(basicNft.balanceOf(USER), 1);
        assert(keccak256(abi.encodePacked(basicNft.tokenURI(0))) == keccak256(abi.encodePacked(PUG)));
    }

    function testMultipleMintIncrementCounter() external {
        vm.startPrank(USER);
        basicNft.mintNFT(PUG);
        basicNft.mintNFT(SHIBA);
        vm.stopPrank();

        assertEq(basicNft.ownerOf(0), USER);
        assertEq(basicNft.ownerOf(1), USER);
        assertEq(basicNft.balanceOf(USER), basicNft.getTokenCount());
    }

    function test_WithEmptyURI() external{
        vm.prank(USER);
        basicNft.mintNFT("");

        assertEq(basicNft.tokenURI(0), "");
    }
    /*//////////////////////////////////////////////////////////////
                             TRANSFER TESTS
    //////////////////////////////////////////////////////////////*/

    function test_TransferNFt() external {
        vm.startPrank(USER);
        basicNft.mintNFT(PUG);
        //transferFrom
        basicNft.transferFrom(USER, STRANGER, 0);
        vm.stopPrank();
        assertEq(basicNft.balanceOf(USER), 0);
        assertEq(basicNft.balanceOf(STRANGER), 1);
        assertEq(basicNft.ownerOf(0), STRANGER);
    }

    function test_CanNotTransferWithoutApproval() external mintNftUser{
        //user mints nft
        //other user tries to transfer nft without approval
        vm.prank(STRANGER);
        address spender = STRANGER;
        uint256 tokenId = 0;
        bytes memory expectedError = abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, spender, tokenId);
        vm.expectRevert(expectedError);
        basicNft.transferFrom(USER, STRANGER, 0);
    }

    function test_RevertWhen_SafeTranferToContractNotCompatibleWithERC721() external mintNftUser{
        //Contract not implemented onERC721Received()
        MockContract mock = new MockContract();
        vm.prank(USER);
        address to = address(mock);
        bytes memory expectedError = abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to);
        vm.expectRevert(expectedError);
        basicNft.safeTransferFrom(USER, address(mock), 0);
    }
}
