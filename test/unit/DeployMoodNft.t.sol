// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import { Test, console } from 'forge-std/Test.sol';
import { DeployMoodNft } from 'script/DeployMoodNft.s.sol';
import { MoodNft } from 'src/MoodNft.sol';

contract DeployMoodNftTest is Test {
    DeployMoodNft deployMoodNft;
    MoodNft moodNft;

    function setUp() external {
        deployMoodNft = new DeployMoodNft();
        moodNft = deployMoodNft.run();
    }

    function testViewSvgToImageUri() view external {
        string memory expectedUri = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iNTAwIiBoZWlnaHQ9IjUwMCI+PHRleHQgeD0iMCIgeT0iMTUiIGZpbGw9ImJsYWNrIj5IaSEgWW91ciBicm93c2VyIGRlY29kZWQgdGhpczwvdGV4dD48L3N2Zz4=";
        string memory validPath = "./img/example.svg";
        assertTrue(vm.exists(validPath));
        string memory readSvg = vm.readFile(validPath);
        string memory returnedURI = deployMoodNft.svgToImageUri(readSvg);
        assertEq(keccak256(abi.encodePacked(expectedUri)), keccak256(abi.encodePacked(returnedURI)));
    }
}