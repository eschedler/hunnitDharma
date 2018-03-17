pragma solidity ^0.4.16;

contract WhiteList {
    
    function verifyAddress(address agentAddress) public returns (bool) {
        if (agentAddress == 0x00000000000000000001) {
            return true;
        } else {
            return false;
        }
    }
    
}