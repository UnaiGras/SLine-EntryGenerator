//SPDX-License-Identifier: MIT

pragma solidity >=0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SellerContract.sol";


contract TiketFactory is ownable {

    //@notice platform fee for create nwe SellerContract.
    uint256 public platformFee;

    //@notice 
    uint256 public mintFee;

    address payable feeReceipient;


    mapping(address => bool) private approvedContract;

    event ContractCreated(address indexed creator, address indexed contract);



    constructor(
        uint256 _platformFee,
        address payable _feeReceipient,
        ) {
        platformFee = _platformFee;
        feeReceipient = _feeReceipient
    } 


    
    function updateFeeReceipient(address payable _newReceipientt) public onlyOwner {
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
            _symbol,
        );

        approveSellerContract(address(seller));
        seller.tranferOwnerShip(msg.sender);
        emit ContractCreated(msg.sender, address(seller))

        return address(seller)

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
        if (approvedContract[sellerContract] != address(0)){

            return true;

        } else {

            revert TiketGenerator__NotApprovedContract(sellerContract);

        }

    }

    modifier onlyApprovedContracts() {
        bool approve = isApprovedContract(msg.sender);

        if (approve == true){
            _;
        }

        revert TiketGenerator__NotApprovedContract(msg.sender);

    }

}


