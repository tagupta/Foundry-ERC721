// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Encoding {
    function combineStrings() pure external returns(string memory){
        return string(abi.encodePacked("heyy", "monnn"));
    }

    function encodeNumber() pure external returns(bytes memory){
        return abi.encode(1);
    }

    function enodeString() pure public returns(bytes memory){
        bytes memory str = abi.encode("some string");
        return str;
    }

    function multiEncode() pure public returns(bytes memory str){
        str = abi.encode("some string", "it's big");
    }

    function multiEncodePacked() pure public returns(bytes memory str){
        str = abi.encodePacked("some string", "it's bigger");
    }

    function encodeLongString() pure external returns(bytes memory, uint256, string memory){
        bytes memory str = abi.encode("some string");
        uint length;
        string memory data;
        assembly {
            //calculating the length of the data
            length := mload(str)
            //calculating the start of data, skipping the data length
            let dataStart := add(str, 0x20)
            
            //data is now pointing to free memory pointer
            data := mload(0x40)

            //store the length in the first 32 bytes of data pointer first
            mstore(data, length)

            //store rest of the str data to data pointer
            // mstore(add(data, 0x20), mload(dataStart))

            let i := 0
            for {} lt(i,length) {}{
                mstore8(add(add(data, 0x20), i), byte(0, mload(add(dataStart, i))))
                i := add(i,1)
            }

            //update free pointer, make this point to the end of data
            mstore(0x40, add(add(data, 0x20), length))
            
        }
        return (str, str.length, data);
    }

    function encodeByteShortStrings() pure external returns(bytes memory str, uint256, string memory) {
        str = abi.encode("abc");
        uint length;
        string memory data;
        assembly {
            length := mload(str)
            let dataStart := add(str, 0x20)
            data := mload(0x40)
            mstore(data, length)
            mstore(add(data, 0x20), mload(dataStart))
            //update free memory pointer
            mstore(0x40, add(add(data, 0x20), length))
        }
        return (str, str.length, data);
    }

    function encodeStringPacked() pure external returns(bytes memory){
        bytes memory str = abi.encodePacked("some string");
        return str;
    }

    function decodeString() pure external returns(string memory){
        string memory someString = abi.decode(enodeString(), (string));
        return someString;
    }

    function multiDecode() pure external returns(string memory str1, string memory str2){
        (str1, str2) = abi.decode(multiEncode(), (string, string));
    }
    
    //Decoding of tightly packed data won't happen like this
    //This doen't work
    function mutliDecodePacked() pure external returns(string memory str1, string memory str2) {
        (str1, str2) = abi.decode(multiEncodePacked(), (string, string));
    }

    function multiDecodeTypeCast() pure external returns(string memory str){
        str = string(multiEncodePacked());
    }

    function passingDataToTransaction() public returns(string memory str){
        (bool result, bytes memory data) = address(this).call(abi.encodeWithSignature("decodeString()"));
        if(result){
            str = abi.decode(data, (string)) ;
            
        }
        else{
            revert("Error occured");
        }
    }

    
}