// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

library ONFT721EnumerableStorage {
    struct Layout {
        string baseTokenURI;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.onft721enumerable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = 0x85fe181c183f62f4c3645b58cc89f6b95a0f60bbf7704c33df5b2a7606e50b00;

    function _getONFT721EnumerableStorage() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}