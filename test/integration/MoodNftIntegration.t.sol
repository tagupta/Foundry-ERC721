// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "src/MoodNft.sol";
import {DeployMoodNft} from 'script/DeployMoodNft.s.sol';

contract MoodNftIntegrationTest is Test {
    MoodNft moodNft;
    DeployMoodNft deployer;
    address private USER = makeAddr("user");
    string private constant SAD_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+CiAgPCEtLSBMaWdodCBibHVlIGZhY2UgY2lyY2xlIC0tPgogIDxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjQ1IiBmaWxsPSIjQUREOEU2IiBzdHJva2U9IiMwMDAiIHN0cm9rZS13aWR0aD0iMiIvPgogIAogIDwhLS0gRG93bndhcmQtbG9va2luZyBleWVzIC0tPgogIDxjaXJjbGUgY3g9IjM1IiBjeT0iNDAiIHI9IjUiIGZpbGw9IiMwMDAiLz4KICA8Y2lyY2xlIGN4PSI2NSIgY3k9IjQwIiByPSI1IiBmaWxsPSIjMDAwIi8+CiAgCiAgPCEtLSBGcm93bmluZyBtb3V0aCAtLT4KICA8cGF0aCBkPSJNMzAgNzAgUTUwIDU1IDcwIDcwIiAKICAgICAgICBzdHJva2U9IiMwMDAiIAogICAgICAgIHN0cm9rZS13aWR0aD0iMyIgCiAgICAgICAgZmlsbD0ibm9uZSIgCiAgICAgICAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8+Cjwvc3ZnPg==";

    string private constant HAPPY_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+CiAgPCEtLSBZZWxsb3cgZmFjZSBjaXJjbGUgLS0+CiAgPGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNDUiIGZpbGw9IiNGRkQ3MDAiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLXdpZHRoPSIyIi8+CiAgCiAgPCEtLSBTaW1wbGUgZXllcyAtLT4KICA8Y2lyY2xlIGN4PSIzNSIgY3k9IjQwIiByPSI1IiBmaWxsPSIjMDAwIi8+CiAgPGNpcmNsZSBjeD0iNjUiIGN5PSI0MCIgcj0iNSIgZmlsbD0iIzAwMCIvPgogIAogIDwhLS0gU21pbGluZyBtb3V0aCAtLT4KICA8cGF0aCBkPSJNMzAgNjAgUTUwIDc1IDcwIDYwIiAKICAgICAgICBzdHJva2U9IiMwMDAiIAogICAgICAgIHN0cm9rZS13aWR0aD0iMyIgCiAgICAgICAgZmlsbD0ibm9uZSIgCiAgICAgICAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIi8+Cjwvc3ZnPg==";

    function setUp() external {
        // moodNft = new MoodNft(SAD_SVG_URI, HAPPY_SVG_URI);
        deployer = new DeployMoodNft();
        moodNft = deployer.run(); 
    }

    function testViewTokenURIIntegration() external {
        vm.prank(USER);
        moodNft.mintNft();
        string memory tokenUri = moodNft.tokenURI(0);
        console.log(tokenUri);
    }

    function testFlipTokenToSad() external {
        vm.startPrank(USER);
        moodNft.mintNft();
        moodNft.flipMood(0);
        vm.stopPrank();
        assert(moodNft.getMoodFromId(0) == MoodNft.Mood.SAD);
    }
}
