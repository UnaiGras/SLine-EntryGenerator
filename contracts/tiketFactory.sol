//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SellerContract.sol";

error TiketGenerator__NotApprovedContract();


contract TiketFactory is Ownable {

    //@notice platform fee for create nwe SellerContract.
    uint256 public platformFee;

    //@notice 
    uint256 public mintFee;

    address payable feeReceipient;


    mapping(address => bool) private approvedContract;

    event ContractCreated(address indexed creator);



    constructor(
        uint256 _platformFee,
        address payable _feeReceipient,
        uint256 _mintFee
    ) {
        platformFee = _platformFee;
        feeReceipient = _feeReceipient;
        mintFee = _mintFee;
    } 


    
    function updateFeeReceipient(address payable _newReceipient) public onlyOwner {
        feeReceipient = _newReceipient;

    }

    function updateMintFee(uint256 _newMintFee) public onlyOwner {
        mintFee = _newMintFee;
    }
    
    
    
    function setNewPlatformFee(uint256 _newFee) public onlyOwner {
        platformFee = _newFee;

    }



    function createNewSeller(string memory _name, string memory _symbol) 
        public 
        payable 
        returns(address)
    {
        require(msg.value >= platformFee, "Insuficient Founds");
        (bool success, ) = feeReceipient.call{value: msg.value}("");
        require (success, "Transaction failed");

        SellerContract seller = new SellerContract(
            _name,
            feeReceipient,
            mintFee,
            _symbol
        );

        approveSellerContract(address(seller));
        seller.transferOwnership(msg.sender);
        emit ContractCreated(msg.sender);

        return address(seller);

    }


    //esta funcion va dentro de CreateNewContract
    function approveSellerContract(address sellerContract) internal onlyOwner {
        require(approvedContract[sellerContract] == false, "This address is alredy approved");

        approvedContract[sellerContract] = true;

    }

    function desapproveSellerContract(address sellerContract) public onlyOwner {
        require(approvedContract[sellerContract], "This address is not aproved");
        approvedContract[sellerContract] = false;

    }

    function isApprovedContract(address sellerContract) public view returns(bool) {
        if (approvedContract[sellerContract] == true){

            return true;

        } else {

            revert TiketGenerator__NotApprovedContract();

        }

    }

    modifier onlyApprovedContracts() {
        bool approve = isApprovedContract(msg.sender);

        if (approve == true){
            _;
        }

        revert TiketGenerator__NotApprovedContract();

    }

}