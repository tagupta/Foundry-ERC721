// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "@foundry-devops/src/DevOpsTools.sol";
import {BasicNft} from "src/BasicNft.sol";

contract MintBasicNft is Script {
    string public constant PUG = "ipfs://QmcX8ncdt8WTDfzzrhiQ1R8fpw42jAz4oTbZ2rR9YkNgoQ/?filename=0-PUG.json";

    function run() external {
        //will work with the most recently deployed contract
        address contractAddress = DevOpsTools.get_most_recent_deployment("BasicNft", block.chainid);
        mintNftOnContract(contractAddress);
    }

    function mintNftOnContract(address contractAddress) public {
        BasicNft basicNft = BasicNft(contractAddress);
        vm.startBroadcast();
        basicNft.mintNFT(PUG);
        vm.stopBroadcast();
    }
}

import {MoodNft} from "src/MoodNft.sol";

contract MintMoodNft is Script {
    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("MoodNft", block.chainid);
        mintMoodNftOnContract(contractAddress);
    }

    function mintMoodNftOnContract(address contractAddress) public {
        MoodNft moodNft = MoodNft(contractAddress);
        vm.startBroadcast();
        moodNft.mintNft();
        vm.stopBroadcast();
    }
}

contract FlipMoodNft is Script {
     uint256 public constant TOKEN_ID_TO_FLIP = 0;

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("MoodNft", block.chainid);
        flipMoodNftOnContract(contractAddress);
    }

    function flipMoodNftOnContract(address contractAddress) public {
        vm.startBroadcast();
        MoodNft(contractAddress).flipMood(TOKEN_ID_TO_FLIP);
        vm.stopBroadcast();
    }
}
