// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { ERC721EnumerableUpgradeable, ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import { ONFT721CoreUpgradeable } from "./ONFT721CoreUpgradeable.sol";

/**
 * @title ONFT721Enumerable Contract
 * @dev ONFT721 is an ERC-721 token that extends the functionality of the ONFT721Core contract.
 */
abstract contract ONFT721EnumerableUpgradeable is ONFT721CoreUpgradeable, ERC721Upgradeable, ERC721EnumerableUpgradeable {
    struct ONFT721EnumerableStorage {
        string baseTokenURI;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.onft721enumerable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ONFT721EnumerableStorageLocation = 0x85fe181c183f62f4c3645b58cc89f6b95a0f60bbf7704c33df5b2a7606e50b00;

    function _getONFT721EnumerableStorage() internal pure returns (ONFT721EnumerableStorage storage ds) {
        assembly {
            ds.slot := ONFT721EnumerableStorageLocation
        }
    }

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
        __ONFT721Core_init(_lzEndpoint, _delegate);
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
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
        if (_from != ERC721Upgradeable.ownerOf(_tokenId)) revert OnlyNFTOwner(_from, ERC721Upgradeable.ownerOf(_tokenId));
        _burn(_tokenId);
    }

    function _credit(address _to, uint256 _tokenId, uint32 /*_srcEid*/) internal virtual override {
        _mint(_to, _tokenId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}