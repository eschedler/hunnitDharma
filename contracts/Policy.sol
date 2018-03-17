pragma solidity ^0.4.16;

contract WhiteList {
    function verifyAddress(address agentAddress) returns (bool);
}

contract Pool {
    function disbursePayment(address[5] beneficiaries, uint[5] payments) payable;
}

contract Policy {
    
    uint public premiumRateGWei;
    uint public coverageId;
    address public policyHolder;
    uint public effectiveTimestamp;
    uint public numMonthsPaid;
    
    address whiteListContract = 0x5e72914535f202659083db3a02c984188fa26e9f;
    address poolContract = 0xbcaafb4802c27917d29449c8ab707ff6f86193ef;
    
    struct Claim {
        uint timestampOfFiling;
        address[5] beneficiaryIds;
    }
    uint nextClaimId;
    
    mapping(uint => Claim) public filedClaims;
    
    event logStr(string s);
    
    
    
    function Policy(
        uint _premiumRateGWei,
        uint _coverageId,
        address _policyHolder
    ) public {
        premiumRateGWei = _premiumRateGWei;
        coverageId = _coverageId;
        policyHolder = _policyHolder;
        
        effectiveTimestamp = now;
        numMonthsPaid = 0;
        nextClaimId = 0;
    }
    
    
    
    function payPremium() public payable {
        uint gWeiSent = msg.value / 1000000000;
        
        require(gWeiSent == premiumRateGWei);
        
        numMonthsPaid += 1;
        
        Pool pool = Pool(poolContract);
        pool.payPremium(msg.value);
    }
    
    
    
    function fileClaim(address[5] beneficiaryIds) public {
        require(policyHolder == msg.sender);
        
        nextClaimId += 1;
        
        filedClaims[nextClaimId].timestampOfFiling = now;
        for (uint i = 0; i < 5; i++) {
            filedClaims[nextClaimId].beneficiaryIds[i] = beneficiaryIds[i];
        }
    }
    
    
    
    function cancelClaim(uint id) public {
        require(verifyInsuranceAgent(msg.sender));
        removeFiledClaim(id);
    }
    
    
    
    function removeFiledClaim(uint id) internal {
        filedClaims[id].timestampOfFiling = 0;
        for (uint i = 0; i < 5; i++) {
            filedClaims[id].beneficiaryIds[i] = 0x0;
        }
    }
    
    
    
    function getFiledClaimAddresses(uint id) returns (address[5]) {
        return filedClaims[id].beneficiaryIds;
    }
    
    
    
    function payClaim(uint id, uint[5] paymentsGWei) public payable {
        require(verifyInsuranceAgent(msg.sender));
        
        address[5] beneficiaryIds;
        
        for (uint i = 0; i < 5; i++) {
            beneficiaryIds[i] = filedClaims[id].beneficiaryIds[i];
        }
        
        removeFiledClaim(id);
        
        Pool pool = Pool(poolContract);
        pool.disbursePayment(beneficiaryIds, paymentsGWei);
    }
    
    
    
    function toString(address x) internal returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }
    
    
    
    function verifyInsuranceAgent(address agentAddress) public returns (bool) {
        return true;
        /*
        WhiteList whiteList = WhiteList(whiteListContract);
        return whiteList.verifyAddress(agentAddress);
        */
    }
    
}