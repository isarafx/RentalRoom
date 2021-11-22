//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract RentalRoom {
    mapping(address => Customer) _account;
    
    uint256 rentalPrice = 2;
    uint256 rentalPeriod = 86400;
    address owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address renter = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address pRenter = msg.sender;
    
    struct Customer {
        address addr;
        bool rental ;
        uint256 timeStart;
        uint256 rentalTime;
    }


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    function ethToWei(uint256 eth_value) public view returns(uint256 ethwei){
        return uint256(eth_value * 1000000000000000000);
    }
     
    function weiToEth(uint256 wei_value) public view returns(uint256 weieth){
        return uint256(wei_value / 1000000000000000000);
    }
    
    function setDataprice(uint256 reprice) public onlyOwner {
        rentalPrice = reprice;
    }
    
    function setDatalocktime(uint256 locktime) public onlyOwner {
        rentalPeriod = locktime;
    }
    
    function checkTime() public view returns(string memory ctime) {
        uint hour = ((_account[msg.sender].rentalTime - block.timestamp)/3600);
        uint min = ((_account[msg.sender].rentalTime - block.timestamp)%3600)/60;
        uint sec = (((_account[msg.sender].rentalTime - block.timestamp)%3600)%60)/1;
        string memory sHour = uint2str(hour);
        string memory sMin = uint2str(min);
        string memory sSec = uint2str(sec);
        string memory colon = ' : ';
        return string(abi.encodePacked(sHour,colon,sMin,colon,sSec));
    }
    
    function checkRenter() public view returns(address caddr,bool cRental) {
        return (_account[renter].addr,_account[renter].rental);
    }
    
    function checkRentalPrice() public view returns(uint256 crentalPrice) {
        return (rentalPrice);
    }
    
    modifier cost(uint _amount) {
        require(msg.value == _amount*1000000000000000000, 'Can not pay for reantal require 2 ether');
        _;
    }
    
    function payForRent() public payable cost(rentalPrice){
        require(_account[renter].rental == false,'Alrady have renter');
        _account[msg.sender].addr = msg.sender;
        _account[msg.sender].rental = true;
        payable(owner).transfer(rentalPrice*1000000000000000000);
        _account[msg.sender].timeStart = block.timestamp;
        _account[msg.sender].rentalTime = block.timestamp + rentalPeriod;
        renter = _account[msg.sender].addr;
    }
    
    function checkOutForOwner() public onlyOwner{
        require(block.timestamp >= _account[renter].rentalTime && _account[renter].rental == true,'Alrady do that');
        _account[renter].rental = false;
        renter = owner;
    }
    
    function continueRent() public payable cost(rentalPrice){
        require(_account[msg.sender].addr == renter,'You are not renter');
        payable(owner).transfer(rentalPrice*1000000000000000000);
        _account[msg.sender].rentalTime += rentalPeriod; 
    }
    
    function openTheDoor() public {
        require(block.timestamp <= _account[renter].rentalTime);
        require(_account[msg.sender].addr == renter && _account[msg.sender].rental == true,'You are not renter');
        require(_account[msg.sender].rental == false, 'The door opened');
    }
    

}