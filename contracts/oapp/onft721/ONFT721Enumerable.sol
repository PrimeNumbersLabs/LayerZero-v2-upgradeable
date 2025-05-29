// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { SolidStateERC721 } from "@solidstate/contracts/token/ERC721/SolidStateERC721.sol";

import { ONFT721Core } from "./ONFT721Core.sol";

/**
 * @title ONFT721Enumerable Contract
 * @dev ONFT721 is an ERC-721 token that extends the functionality of the ONFT721Core contract.
 */
abstract contract ONFT721Enumerable is ONFT721Core, SolidStateERC721 {

    event BaseURISet(string baseURI);

    /**
     * @dev Constructor for the ONFT721 contract.
     * @param _name The name of the ONFT.
     * @param _symbol The symbol of the ONFT.
     * @param _lzEndpoint The LayerZero endpoint address.
     * @param _delegate The delegate capable of making OApp configurations inside of the endpoint.
     */
    function __ONFT721Enumerable_init(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) internal onlyInitializing {
        __ERC721_init(_name, _symbol);
        __ONFT721Core_init(_lzEndpoint, _delegate);
    }

    /**
     * @notice Retrieves the address of the underlying ERC721 implementation (ie. this contract).
     */
    function token() external view returns (address) {
        return address(this);
    }

    function setBaseURI(string calldata _baseTokenURI) external onlyOwner {
        ONFT721EnumerableStorage storage $ = _getONFT721EnumerableStorage();
        $.baseTokenURI = _baseTokenURI;
        emit BaseURISet($.baseTokenURI);
    }

    function _baseURI() internal view override returns (string memory) {
        ONFT721EnumerableStorage storage $ = _getONFT721EnumerableStorage();
        return $.baseTokenURI;
    }

    /**
     * @notice Indicates whether the ONFT721 contract requires approval of the 'token()' to send.
     * @dev In the case of ONFT where the contract IS the token, approval is NOT required.
     * @return requiresApproval Needs approval of the underlying token implementation.
     */
    function approvalRequired() external pure virtual returns (bool) {
        return false;
    }

    function _debit(address _from, uint256 _tokenId, uint32 /*_dstEid*/) internal virtual override {
        if (_from != ERC721.ownerOf(_tokenId)) revert OnlyNFTOwner(_from, ERC721.ownerOf(_tokenId));
        _burn(_tokenId);
    }

    function _credit(address _to, uint256 _tokenId, uint32 /*_srcEid*/) internal virtual override {
        _mint(_to, _tokenId);
    }
}