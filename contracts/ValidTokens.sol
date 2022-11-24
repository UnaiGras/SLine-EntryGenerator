//SPDX-License-Identifier: Unlicensed


pragma solidity 0.8.17;


import "@openzeppelin/contracts/access/Ownable.sol";


contract ValidTokens is Ownable {

    /**Mapping of Approved tokens to use in the marketplace */

    mapping(address => bool) public enabledToken;

    /**Events */

    event TokenAdded(address token);
    event TokenRemoved(address token);

    /**@notice Funcions, AddToken and RemoveToken
     * @dev onlyOwner 
     */

    function add(address newToken) public onlyOwner{
        require(!enabledToken[newToken],"Token alredy exist.");
        enabledToken[newToken] = true;
        emit TokenAdded(newToken);
    }

    function remove(address token) public onlyOwner {
        require(enabledToken[token],"This token doesn't exist");
        enabledToken[token] = false;
        emit TokenRemoved(token);
    }
}