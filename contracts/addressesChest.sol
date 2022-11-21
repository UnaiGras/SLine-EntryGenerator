//SPDX-License-Identfier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AddressesChest is Ownable {

    //ValidTokens address

    address public validTokens;

    //tiketFactory address

    address public tiketFactory;

    //SLine marketplace address

    address public slineMarketplace;


    //Update ValidTokens
    function updateValidTokens(address _new) external onlyOwner{
        validTokens = _new;
    }

    //Update TiketFactory
    function updateTiketFactory(address _new) external onlyOwner{
        tiketFactory = _new;
    }

    //Update SLineMarketplace
    function updateSlineMarketplace(address _new) external onlyOwner{
        slineMarketplace = _new;
    }















}