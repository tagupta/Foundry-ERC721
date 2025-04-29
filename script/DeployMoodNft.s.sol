// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {MoodNft} from "src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNft is Script {
    MoodNft moodNft;

    function run() external returns (MoodNft) {
        string memory sadSvg = vm.readFile("./img/sadFace.svg");
        string memory happySvg = vm.readFile("./img/happyFace.svg");
        string memory sadImageUri = svgToImageUri(sadSvg);
        string memory happyImageUri = svgToImageUri(happySvg);
        vm.startBroadcast();
        moodNft = new MoodNft(sadImageUri, happyImageUri);
        vm.stopBroadcast();
        return moodNft;
    }

    function svgToImageUri(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = string(Base64.encode(bytes(string(abi.encodePacked(svg)))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
