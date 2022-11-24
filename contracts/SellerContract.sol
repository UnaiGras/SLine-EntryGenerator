//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev Implementation of Multi-Token Standard contract
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./ISellerContract.sol";

contract SellerContract is Ownable, ERC165, ISellerContract {

  //** */

    uint256 public platformFee;

    address payable feeReceipient;

    string public name;

    string public symbol;

    uint256 public tokenIdCounter = 0;

    bool initialized = false;

  //** */

    mapping (uint256 => Entrys) private _idForEntry;
    mapping (uint256 => bool) public ids;

  // Objects balances
    mapping (address => mapping(uint256 => uint256)) internal balances;

  // Operator Functions
    mapping (address => mapping(address => bool)) internal operators;

  // Events
    event EntrysSelled(uint256 _supply, uint256 _id, address _to);
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _uri, uint256 indexed _id);


    struct Entrys {
        string name;
        uint256 id;
        uint256 maxSupply;
        string tokenURI;
        uint256 mintPrice;
    }

    constructor (
        string memory _name,
        address payable _feeReceipient,
        uint256 _platformFee,
        string memory _symbol
    ) {
        name = _name;
        feeReceipient = _feeReceipient;
        platformFee = _platformFee;
        symbol = _symbol;
    }





    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(ISellerContract).interfaceId ||
            super.supportsInterface(interfaceId);
    }

  /***********************************|
  |     Public Transfer Functions     |
  |__________________________________*/


    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
      public
      override
    {
      require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
      require(_to != address(0),"ERC1155#safeTransferFrom: INVALID_RECIPIENT");
      // require(_amount >= balances[_from][_id]) is not necessary since checked with safemath operations

      _safeTransferFrom(_from, _to, _id, _amount);
    }


    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
      public
      virtual
      override
    {
      // Requirements
      require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
      require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

      _safeBatchTransferFrom(_from, _to, _ids, _amounts);

    }

    function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
      public
      virtual 
    {
      // Update balances
      balances[_from][_id] = balances[_from][_id] - _amount; // Subtract amount
      balances[_to][_id] = balances[_to][_id] + _amount;     // Add amount

      // Emit event
      emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }


    function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts)
     internal
    {
     require(_ids.length == _amounts.length, "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH");

     // Number of transfer to execute
     uint256 nTransfer = _ids.length;

     // Executing all transfers
     for (uint256 i = 0; i < nTransfer; i++) {
       // Update storage balance of previous bin
       balances[_from][_ids[i]] = balances[_from][_ids[i]] - _amounts[i];
       balances[_to][_ids[i]] = balances[_to][_ids[i]] + _amounts[i];
     }
    }

 
  function setApprovalForAll(address _operator, bool _approved)
    external
    override
  {
    // Update operator status
    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  
    function isApprovedForAll(address _owner, address _operator)
     public view virtual override returns (bool isOperator)
    {
     return operators[_owner][_operator];
    }


  /***********************************|
  |         Balance Functions         |
  |__________________________________*/


    function balanceOf(address _owner, uint256 _id)
     public view override returns (uint256)
    {
     return balances[_owner][_id];
    }


    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
     public view override returns (uint256[] memory)
    {
     require(_owners.length == _ids.length, "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH");

     // Variables
     uint256[] memory batchBalances = new uint256[](_owners.length);

     // Iterate over each owner and token ID
     for (uint256 i = 0; i < _owners.length; i++) {
       batchBalances[i] = balances[_owners[i]][_ids[i]];
     }

     return batchBalances;
    }


    function init() public onlyOwner {
      require(initialized == false, "The contract is alredy initialitzed");
      initialized = true;
    }



    function setBatchTokensFeatures(
        string[] memory _name,
        uint256[] memory _supply,
        string[] memory _uri,
        uint256[] memory _price
    ) public override onlyOwner {
        require(
            _name.length == _supply.length && _supply.length == _uri.length && _uri.length == _price.length,
            "The length of features dont match"
        );
        require(initialized == true, "The contract in not initialized");

        uint256 nTokens = _name.length;

        for(uint256 i; i <= nTokens; i++) {
            _newTokenId();
            ids[_currentTokenId()] = true;
            _idForEntry[_currentTokenId()].name = _name[i];
            _idForEntry[_currentTokenId()].id = _currentTokenId();
            _idForEntry[_currentTokenId()].maxSupply = _supply[i];
            _idForEntry[_currentTokenId()].tokenURI = _uri[i];
            _idForEntry[_currentTokenId()].mintPrice = _price[i];
        } 

    }



    function SetNewTokenFeatures(
        string memory _name,
        uint256 _supply,
        string memory _uri,
        uint256 _price
    ) public override onlyOwner {

        require(initialized == true, "The contract in not initialized");
        _newTokenId();
        _idForEntry[_currentTokenId()].name = _name;
        _idForEntry[_currentTokenId()].id = _currentTokenId();
        _idForEntry[_currentTokenId()].maxSupply = _supply;
        _idForEntry[_currentTokenId()].tokenURI = _uri;
        _idForEntry[_currentTokenId()].mintPrice = _price;
    } 



    function mint(
        address _to,
        uint256 _id,
        uint256 _supply
    ) public override payable {
        require(initialized == true, "The contract in not initialized");
        require(_to != address(0), "Invalid address.");
        require(_supply <= _idForEntry[_id].maxSupply, "All entrys are selled.");

        uint256 price = _idForEntry[_id].mintPrice * _supply;
        uint256 fee = caculatePlatformMintFee(_id, _supply);

        require(msg.value >= price + fee, "Insuficient Founds.");
        (bool success, ) = feeReceipient.call{value: fee}("");
        require(success, "Transaction failed.");
        (bool Success, ) = address(this).call{value: price}("");
        require(Success, "Transaction failed.");


        balances[_to][_id] = _supply;
        emit EntrysSelled(_supply, _id, _to);
    }


    function withdraw() public override onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }


    
    function setTokenURI(uint256 _id, string memory _uri) public override onlyOwner  {
        require(_exists(_id), "Token id doesn't exist");
        _idForEntry[_id].tokenURI = _uri;
    }


    function setTokenSupply(uint256 _id, uint256 _supply) public override onlyOwner {
        require(_exists(_id), "Token id doesn't exist");
         _idForEntry[_id].maxSupply = _supply;

    } 


    function setTokenName(uint256 _id, string memory _name) public override onlyOwner {
        require(_exists(_id), "Token id doesn't exist");
         _idForEntry[_id].name = _name;

    }

    
    function _exists( uint256 _id ) public view override returns(bool) {
        require(ids[_id] == true, "Token id doesn't exist");

        return true;
    }


    function tokenSupply( uint256 _id) public view override returns(uint256) {

        require(_exists(_id), "Token id doesn't exist");
        uint256 totalSupply = _idForEntry[_id].maxSupply;
        return totalSupply;
    }


    function _currentTokenId() public view override returns(uint256) {
        return tokenIdCounter;
    }


    function _newTokenId() internal {
        tokenIdCounter += 1;
    }


    //function para calcular el precio de minteo que se lleva la plataforma. Seria _idForEntry[_id].mintprice /100 * platformFee (de esta forma lo que se lleva el receipt es porcentual al mint price de cada minteo.
    function caculatePlatformMintFee(uint256 _id, uint256 _supply) public view override returns(uint256){
        uint256 mintPrice = _idForEntry[_id].mintPrice;
        uint256 _FeePerSupply = mintPrice / 100 * platformFee;
        uint256 _platformFee = _FeePerSupply * _supply;
        return _platformFee;
    }

    function transferOwnership(address newOwner) public override onlyOwner{
        _transferOwnership(newOwner);
    }
}
