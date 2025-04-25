// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployBasicNft} from "script/DeployBasicNft.s.sol";
import {BasicNft} from "src/BasicNft.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {NftReceiver} from "src/NftReceiver.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Vm} from "forge-std/Vm.sol";

contract MockContract {
    constructor() {}
}

contract BasicNftTest is Test {
    DeployBasicNft deployer;
    BasicNft basicNft;
    address public USER = makeAddr("user");
    address public STRANGER = makeAddr("stranger");
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

    function test_InitialCounterValueIsZero() external view {
        uint256 initalTokenCount = basicNft.getTokenCount();
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

    function test_WithEmptyURI() external {
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

    function test_CanNotTransferWithoutApproval() external mintNftUser {
        //user mints nft
        //other user tries to transfer nft without approval
        vm.prank(STRANGER);
        address spender = STRANGER;
        uint256 tokenId = 0;
        bytes memory expectedError =
            abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, spender, tokenId);
        vm.expectRevert(expectedError);
        basicNft.transferFrom(USER, STRANGER, 0);
    }

    function test_RevertWhen_SafeTranferToContractNotCompatibleWithERC721() external mintNftUser {
        //Contract has not implemented onERC721Received()
        MockContract mock = new MockContract();
        vm.prank(USER);
        address to = address(mock);
        bytes memory expectedError = abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to);
        vm.expectRevert(expectedError);
        basicNft.safeTransferFrom(USER, address(mock), 0);
    }

    function test_SafeTransferFromToContractCompatibleWithERC721() external mintNftUser {
        // before going for transfer
        // check if the receipient supports the supportInterface()
        NftReceiver mockNFTReceiver = new NftReceiver();
        bytes4 interfaceId = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
        assert(mockNFTReceiver.supportsInterface(interfaceId) == true);
        vm.prank(USER);

        vm.recordLogs();
        basicNft.safeTransferFrom(USER, address(mockNFTReceiver), 0);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 eventSig = keccak256("NFTReceived(address,address,uint256,bytes,uint256)");

        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == eventSig) {
                address opeartor = address(uint160(uint256(logs[i].topics[1])));
                address from = address(uint160(uint256(logs[i].topics[2])));
                uint256 tokenId = uint256(logs[i].topics[3]);
                assertEq(opeartor, USER);
                assertEq(from, USER);
                assertEq(tokenId, 0);
            }
        }
    }
    /*//////////////////////////////////////////////////////////////
                             APPROVAL TEST
    //////////////////////////////////////////////////////////////*/

    function testApproveNft() external mintNftUser{
        vm.prank(USER);
        basicNft.approve(STRANGER, 0);

        assertEq(basicNft.getApproved(0), STRANGER);
    }

    function testApprovedCanTransfer() external mintNftUser{
        vm.prank(USER);
        basicNft.approve(STRANGER, 0);

        //check if approved address can safely transfer the nft from the nft owner
        vm.prank(STRANGER);
        basicNft.safeTransferFrom(USER, STRANGER, 0);
        assertEq(basicNft.ownerOf(0), STRANGER);
    }

    /*//////////////////////////////////////////////////////////////
                              EDAGE CASES
    //////////////////////////////////////////////////////////////*/
    function testCanNotMintToZeroAddress() external {
        vm.prank(address(0));
        address to = address(0);
        bytes memory expectedError = abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, to);
        vm.expectRevert(expectedError);
        basicNft.mintNFT(PUG);
    }

    function testCanNotTransferNonExistentToken() external mintNftUser{
        vm.prank(USER);
        uint nonMintedTokenId = 999;
        bytes memory expectedError = abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector,nonMintedTokenId );
        vm.expectRevert(expectedError);
        basicNft.safeTransferFrom(USER, STRANGER, nonMintedTokenId);
    }
}
