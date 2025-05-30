// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { SolidStateERC721 } from "@solidstate/contracts/token/ERC721/SolidStateERC721.sol";
import { ERC721MetadataStorage } from "@solidstate/contracts/token/ERC721/metadata/ERC721MetadataStorage.sol";

import { ONFT721Core } from "./ONFT721Core.sol";

/**
 * @title ONFT721Enumerable Contract
 * @dev ONFT721 is an ERC-721 token that extends the functionality of the ONFT721Core contract.
 */
abstract contract ONFT721Enumerable is ONFT721Core, SolidStateERC721 {
    using ERC721MetadataStorage for ERC721MetadataStorage.Layout;

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
    ) internal {
        ERC721MetadataStorage.Layout storage $ = ERC721MetadataStorage.layout();
        $.name = _name;
        $.symbol = _symbol;
        __ONFT721Core_init(_lzEndpoint, _delegate);
    }

    /**
     * @notice Retrieves the address of the underlying ERC721 implementation (ie. this contract).
     */
    function token() external view returns (address) {
        return address(this);
    }

    function setBaseURI(string calldata _baseTokenURI) external onlyOwner {
        ERC721MetadataStorage.Layout storage $ = ERC721MetadataStorage.layout();
        $.baseURI = _baseTokenURI;
        emit BaseURISet($.baseURI);
    }

    function _baseURI() internal view returns (string memory) {
        ERC721MetadataStorage.Layout storage $ = ERC721MetadataStorage.layout();
        return $.baseURI;
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
        if (_from != _ownerOf(_tokenId)) revert OnlyNFTOwner(_from, _ownerOf(_tokenId));
        _burn(_tokenId);
    }

    function _credit(address _to, uint256 _tokenId, uint32 /*_srcEid*/) internal virtual override {
        _mint(_to, _tokenId);
    }
}