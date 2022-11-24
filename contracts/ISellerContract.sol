//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ISellerContract is IERC165 {


    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) external;


    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data) external;


    function setApprovalForAll(address _operator, bool _approved) external;


    function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);


    function balanceOf(address _owner, uint256 _id) external view returns (uint256);


    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids) external view returns (uint256[] memory);


    function setBatchTokensFeatures(string[] memory _name, uint256[] memory _supply, string[] memory _uri, uint256[] memory _price) external;


    function SetNewTokenFeatures(string memory _name, uint256 _supply, string memory _uri, uint256 _price) external;


    function mint(address _to, uint256 _id, uint256 _supply) external payable;


    function withdraw() external;


    function setTokenURI(uint256 _id, string memory _uri) external;


    function setTokenSupply(uint256 _id, uint256 _supply) external;


    function setTokenName(uint256 _id, string memory _name) external;


    function _exists( uint256 _id ) external view returns(bool);


    function tokenSupply( uint256 _id) external view returns(uint256);


    function _currentTokenId() external view returns(uint256);
    

    function caculatePlatformMintFee(uint256 _id, uint256 _supply) external returns(uint256);

}

