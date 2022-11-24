//SPDX-License-Identifier: Unlicensed


pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./ISellerContract.sol";


//Interfaces to call especific functions
interface IaddressesChest {
    function validTokens() external view returns(address);

    function tiketFactory() external view returns(address);
}

interface IValidTokens {
    function enabledToken(address) external view returns (bool);
}

interface ITokenFactory {
    function approvedContract(address) external view returns(bool);
}


contract SLineMarketplace is Ownable {
    /**Events*/

    event EntryListed(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem
    );
    event EntrySold(
        address indexed seller,
        address indexed buyer,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem
    );
    event EntryUpdated(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        address payToken,
        uint256 newPrice
    );
    event EntryCanceled(
        address indexed owner,
        address indexed nft,
        uint256 tokenId

    );
    event OfferCreated(
        address indexed creator,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem
    );
    event OfferCanceled(
        address indexed creator,
        address indexed nft,
        uint256 tokenId
    ); 

    //**structs*/ 
    
    struct Listing {
        uint256 quantity;
        address payToken;
        uint256 pricePerItem;
    }

    struct Offer {
        address payToken;
        uint256 quantity;
        uint256 pricePerItem;
    }

    //**mappings*/

    /// @notice NftAddress -> Token ID -> Owner -> Listing item
    mapping(address => mapping(uint256 => mapping(address => Listing)))
        public listings;

    mapping(address => mapping(uint256 => mapping(address => Offer)))
        public offers;


    uint256 public platformFee;
    
    address payable public feeRecipient;

    //address of storage contract with addresses to call
    IaddressesChest public addressChest;

    bytes4 public constant SELLER_ID = type(ISellerContract).interfaceId; 


    constructor (
        uint256 _platformFee,
        address payable _feeRecipient
    ) {
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
    }

    modifier isListed(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    ) {
        Listing memory listedEntry = listings[_nftAddress][_tokenId][_owner];
        require(listedEntry.quantity > 0,"This entry isn't listed");
        _;
    }    

    modifier notListed(
        address _nftAddress,
        uint256 _tokenId,
        address _owner
    ) {
        Listing memory listing = listings[_nftAddress][_tokenId][_owner];
        require(listing.quantity == 0,"This entry is alredy listed");
        _;
    }

    modifier offerExist(
        address _nftAddress,
        uint256 _tokenId,
        address _creator
    ) {
        Offer memory offer = offers[_nftAddress][_tokenId][_creator];
        require(
            offer.quantity > 0,
            "offer doesn't exist"
        );
        _;
    }

    modifier offerNotExit(
        address _nftAddress,
        uint256 _tokenId,
        address _creator
    ) {
        Offer memory offer = offers[_nftAddress][_tokenId][_creator];
        require(offer.quantity <= 0,"offer alredy exist");
        _;
    }

    /**
      
        PUBLIC FUNCTIONS
      
    */

    function listEntry(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity,
        address _payToken,
        uint256 _pricePerItem
    ) public notListed(_nftAddress, _tokenId, msg.sender){
        require(
            _isSellerToken(_nftAddress),
            "Only accept entry tokens"
        );

        ISellerContract entry = ISellerContract(_nftAddress);

        require(
            entry.balanceOf(msg.sender, _tokenId) >= _quantity, 
            "Insuficient founds"
        );
        require(
            entry.isApprovedForAll(msg.sender, address(this)),
            "Not approved"
        );


        _validPayToken(_payToken);

        listings[_nftAddress][_tokenId][msg.sender] = Listing(
            _quantity,
            _payToken,
            _pricePerItem
        );

        emit EntryListed(
        msg.sender,
        _nftAddress,
        _tokenId,
        _quantity,
        _payToken,
        _pricePerItem
        );
    }

    function updateListedEntry(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _newPrice
    ) public isListed(_nftAddress, _tokenId, msg.sender) 
    {
        Listing storage listedEntry = listings[_nftAddress][_tokenId][msg.sender];

        _validOwner(_nftAddress, _tokenId, msg.sender, listedEntry.quantity);

        _validPayToken(_nftAddress);

        listedEntry.payToken = _payToken;
        listedEntry.pricePerItem = _newPrice;

        emit EntryUpdated(
            msg.sender,
            _nftAddress,
            _tokenId,
            _payToken,
            _newPrice
        );
    }

    function cancelListedEntry(address _nftAddress, uint256 _tokenId) 
        public
        isListed(_nftAddress, _tokenId, msg.sender) 
    {
        _cancelListing(_nftAddress, _tokenId, msg.sender);
    }

    function buyEntry(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        address _owner
    ) 
        public
        isListed(_nftAddress, _tokenId, _owner)
    {
        Listing memory entry = listings[_nftAddress][_tokenId][_owner];
        require(entry.payToken == _payToken,"invalid pay token");

        _validOwner(_nftAddress, _tokenId, _owner, entry.quantity);

        _buyItem(_nftAddress, _tokenId, _payToken, _owner);
    }


    function newOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _quantity,
        uint256 _pricePerItem
    ) public offerNotExit(_nftAddress, _tokenId, msg.sender) {

        require(
            _isSellerToken(_nftAddress), 
            "not valid address"
        );
        require(
            _validPayToken(_payToken),
            "not valid pay token"
        );


        uint256 userBalance = IERC20(_payToken).balanceOf(msg.sender);
        uint256 toPay = _pricePerItem * _quantity;
        require(userBalance >= toPay, "Insufucient founds to  make this offer");


        Offer storage offer = offers[_nftAddress][_tokenId][msg.sender];

        offer.payToken = _payToken;
        offer.quantity = _quantity;
        offer.pricePerItem = _pricePerItem;

        emit OfferCreated(
            msg.sender,
            _nftAddress,
            _tokenId,
            _quantity,
            _payToken,
            _pricePerItem
        );


    }

    function cancelOffer(address _nftAddress, uint256 _tokenId)
        public
        offerExist(_nftAddress, _tokenId, msg.sender) 
    {
        delete (offers[_nftAddress][_tokenId][msg.sender]);
        emit OfferCanceled(msg.sender, _nftAddress, _tokenId);
    }

    function acceptOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _creator
    ) public offerExist(_nftAddress, _tokenId, _creator)
    {
        //intanciar la oferta
        Offer memory offer = offers[_nftAddress][_tokenId][_creator];

        _validOwner(_nftAddress, _tokenId, msg.sender, offer.quantity);

        uint256 price = offer.pricePerItem * offer.quantity;
        uint256 feeAmount = price * platformFee / 100; 
        //comprobar balances de ambos (msg.sender es quien tiene las entradas y creator esquien hizo la offer)
        address tkn = offer.payToken;
        require(_validPayToken(tkn), "invalid pay token");
        

        IERC20(tkn).transferFrom(
            _creator, 
            feeRecipient, 
            feeAmount
        );

        IERC20(tkn).transferFrom(
            _creator,
            msg.sender,
            price - feeAmount
        );

        //Transfer the entry

        ISellerContract(_nftAddress).safeTransferFrom(
            msg.sender,
            _creator,
            _tokenId,
            offer.quantity,
            bytes("")
        );

        emit EntrySold(
            msg.sender,
            _creator,
            _nftAddress,
            _tokenId,
            offer.quantity,
            address(offer.payToken),
            offer.pricePerItem
        );
        
        
        delete (listings[_nftAddress][_tokenId][msg.sender]);
        delete (offers[_nftAddress][_tokenId][_creator]);
        
    }


    /* 
    
        INTERNAL FUNCTIONS
    
    */

   function _buyItem(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        address _owner
   ) private {

        _validPayToken(_payToken);
        Listing memory entry = listings[_nftAddress][_tokenId][_owner];

        uint256 price = entry.pricePerItem * entry.quantity;
        uint256 feeAmount = price * platformFee / 100;

        IERC20(_payToken).transferFrom(
            msg.sender, 
            feeRecipient, 
            feeAmount
        );

        IERC20(_payToken).transferFrom(
            msg.sender, 
            _owner, 
            price - feeAmount
        );

        if (IERC165(_nftAddress).supportsInterface(SELLER_ID)) {
            ISellerContract(_nftAddress).safeTransferFrom(
                _owner,
                msg.sender,
                _tokenId,
                entry.quantity,
                bytes("")
            );
        } else {
            revert("kva");
        }

        emit EntrySold(
            _owner,
            msg.sender,
            _nftAddress,
            _tokenId,
            entry.quantity,
            _payToken,
            entry.pricePerItem
        );
    }

    
    function _isSellerToken(address _nftAddress) internal view returns(bool) {
        bool success = 
        IERC165(_nftAddress).supportsInterface(SELLER_ID) &&
        _isApprovedContract(_nftAddress);
        require(success,"...");
        return true;
    }

    //Escribir todas las functiones que voy  a implementar

    
    function _validPayToken(address tokenAddress) internal view returns(bool) {
         bool success = IValidTokens(addressChest.validTokens()).enabledToken(tokenAddress);
         require(
            success, 
            "Not valid payment"
        );
        return true;  
    }

    function _validOwner(
        address _nftAddress,
        uint256 _tokenId,
        address _owner,
        uint256 _quantity
    ) internal view {
        ISellerContract entry = ISellerContract(_nftAddress);
        require(
            entry.balanceOf(_owner, _tokenId) >= _quantity,
            "Not yours"
        );
    }


    function _isApprovedContract(address _nftAddress) 
        internal 
        view 
        returns(bool) 
    {
        bool isApproved = ITokenFactory(addressChest.tiketFactory()).approvedContract(_nftAddress);
        require(isApproved, "Not approved contract");
        return true;
    }

    function _cancelListing(
        address _nftAddress, 
        uint256 _tokenId, 
        address _owner
    ) internal {
        Listing memory listedEntry = listings[_nftAddress][_tokenId][_owner];

        _validOwner(_nftAddress, _tokenId, _owner, listedEntry.quantity);

        delete (listings[_nftAddress][_tokenId][_owner]);
        emit EntryCanceled(_owner, _nftAddress, _tokenId);
    }
}

/** function para los royalties de las empresas Y DE LOS USUARIOS(1%).*/

