//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract FeeReceipient {
    address private owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    function payFees() public payable {
        balance += msg.value;
    }

    function withdraw() public onlyOwner {
        require(balance>0,"No funds available");
        payable(msg.sender).transfer(balance);
        balance = 0;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Nice try bro");
        _;
    }
    
    receive() external payable{
        balance += msg.value;
    }
}
