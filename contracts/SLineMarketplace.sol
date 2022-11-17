//SPDX-License-Identifier: Unlicensed


pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


//Interfaces to call especific functions

interface IValidTokens {
    function enabledToken(address) external view returns (bool);
}

interface ITokenFactory {
    function approvedContract(address) external view returns(bool);
}


contract SLineMarketplace is Ownable {
    /**Events*/

    event ItemListed(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem
    );
    event ItemSold(
        address indexed seller,
        address indexed buyer,
        address indexed nft,
        uint256 tokenId,
        uint256 quantity,
        address payToken,
        uint256 pricePerItem
    );
    event ItemUpdated(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        address payToken,
        uint256 newPrice
    );
    event ItemCanceled(
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
        uint256 pricePerItem,
        uint256 deadline
    );
    event OfferCanceled(
        address indexed creator,
        address indexed nft,
        uint256 tokenId
    ); 

    //**structs*/ 
    
    struct Listed {
        uint256 quantity;
        address payToken;
        uint256 pricePerItem;
    }

    struct Offer {
        IERC20 payToken;
        uint256 quantity;
        uint256 pricePerItem;
    }

    //**mappings*/


    address tiketFactory;

    uint256 platformFee;
    
    address feeRecipient;






} 



/**hacer ofertas de compra generales de un tipo de entrada*/ 


/*override en SellerContract de transfer, safetra...  para que solo se puedan vender
 a traves de este marketplace.*/

/** function para los royalties de las empresas Y DE LOS USUARIOS(1%).*/

/**function de reconocimiento de contratos(erc165) para que solo se puedan publicar entradas emitidas con el tiketFactory */
