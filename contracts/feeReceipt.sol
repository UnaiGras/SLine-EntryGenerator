//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


contract FeeReceipient {

    address private owner;


    constructor() {
        owner = msg.sender;
    }



    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }




    function payFees() public payable {
        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, "Transaction failed");
    }


    modifier onlyOwner(){
        require(msg.sender == owner, "Nice try bro");
        _;
    }


    fallback() external {
        payFees();
    } 
}