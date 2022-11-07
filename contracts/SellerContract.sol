//SPDX-License-Identifier: MIT

pragma solidity >=0.8.17;

import "./tiketFactory.sol";
import "./library/ERC1155.sol";
import "./library/ERC1155Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract SellerContract is ERC1155, Ownable {

    uint256 public platformFee;

    address payable feeReceipient;

    string public name;

    string public symbol;

    uint256 public tokenIdCounter = 0;


    mapping (uint256 => Entrys) private _idForEntry;
    mapping (uint256 => bool) public ids;

    
    struct Entrys {
        string name;
        uint256 id;
        uint256 maxSupply;
        string tokenURI;
        uint256 mintPrice;
    }

    constructor (
        string _name,
        address payable _feeReceipient,
        uint256 _platformFee,
        string _symbol
    ) public {
        name = _name;
        feeReceipient = _feeReceipient;
        platformFee = _platformFee;
        symbol = _symbol;
    }



    function setBatchTokensFeatures(
        string[] memory _name,
        uint256[] _supply,
        string[] memory _uri,
        uint256[] _price
    ) public onlyOwner {
        require(
            _name.length == _supply.length && _supply.length == _uri.length && _uri.length == _price.length,
            "The length of features dont match"
        );

        uint256 nTokens = _name.length;

        for(uint256 i; i <= nTokens; i++) {
            _newTokenId;
            ids[_currentId] = true;
            _idForEntry[_currentId()].name = _name[i];
            _idForEntry[_currentId()].id = _currentId();
            _idForEntry[_currentId()].maxSupply = _supply[i];
            _idForEntry[_currentId()].tokenURI = _uri[i];
            _idForEntry[_currentId()].mintPrice = _price[i];
        } 

    }



    function SetNewTokenFeatures(
        string memory _name,
        uint256 _supply,
        string memory _uri,
        uint256 _price
    ) public onlyOwner {

        _newTokenId;
        _idForEntry[_currentId()].name = _name;
        _idForEntry[_currentId()].id = _currentId();
        _idForEntry[_currentId()].maxSupply = _supply;
        _idForEntry[_currentId()].tokenURI = _uri;
        _idForEntry[_currentId()].mintPrice = _price;
        } 

    }


    function mint(
        address _to,
        uint256 _id,
        uint256 _supply
    ) public payable {
        require(_to != address(0), "Invalid address.");
        require(_supply <= _idForEntry[_id].maxSupply, "All entrys are selled.");

        uint256 price = _idForEntry[_id].mintPrice * _supply;
        uint256 fee = calculatePlatformFee(_id, _supply);

        require(msg.value >= price + fee, "InsuficientFounds.");
        (bool success, ) = feeReceipt.call{value: fee}("");
        require(success, "Transaction failed.");
        (bool Success, ) = address(this).call{value: price}("");
        require(Success, "Transaction failed.");


        balances[_to][_id] = _supply;
        emit EntrysSelled(_supply, _id, _to);
    }


    function withdraw() public onlyOwner {
        address payable reciver = msg.sender;
        payable(reciver).transfer(address(this).balance);
    }


    
    function setTokenURI(uint256 _id, string memory _uri) internal {
        require(ids[_id] == true, "Token id doesn't exist");
        _idForEntry[_id].tokenURI = _uri;
    }


    function setTokenSupply(uint256 _id, uint256 _supply) internal {
        require(ids[_id] == true, "Token id doesn't exist");
         _idForEntry[_id].maxSupply = _supply;

    } 


    function setTokenName(uint256 _id, string memory _name) internal {
        require(ids[_id] == true, "Token id doesn't exist");
         _idForEntry[_id].name = _name;

    }

    
    function _exists( uint256 _id ) public view returns(bool) {
        require(_creators[_id] != address(0));

        return true;
    }


    function tokenSupply( uint256 _id) public view returns(uint256) {

        require(_creators[_id] != address(0));
        uint256 totalSupply = _idForEntry[_id].maxSupply;
        return totalSupply;
    }


    function _currentTokenId() public view returns(uint256) {
        return tokenIdCounter;
    }


    function _newTokenId() public onlyOwner {
        tokenIdCounter += 1;
    }


    //function para calcular el precio de minteo que se lleva la plataforma. Seria _idForEntry[_id].mintprice /100 * platformFee (de esta forma lo que se lleva el receipt es porcentual al mint price de cada minteo.
    function caculatePlatformMintFee(uint256 _id, uint256 _supply) internal view returns(uint256){
        uint256 mintPrice = _idForEntry[_id].mintPrice;
        uint256 _FeePerSupply = mintPrice / 100 * platformFee;
        uint256 _platformFee = _platformFee * _supply;
        return _platformFee;
    }
}











