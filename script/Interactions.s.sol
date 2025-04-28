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
