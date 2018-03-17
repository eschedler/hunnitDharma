pragma solidity ^0.4.16;

contract Pool {
    
    function disbursePayment(address[5] beneficiaries, uint[5] payments) public payable {
        for (uint i = 0; i < 5; i++) {
            //beneficiaries[i].transfer(payments[i]);
        }
    }
    
}