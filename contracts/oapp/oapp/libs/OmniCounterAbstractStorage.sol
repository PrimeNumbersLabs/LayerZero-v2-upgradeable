// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

library OmniCounterAbstractStorage {
    struct Layout {
        uint256 count;
        uint256 composedCount;
        address admin;
        uint32 eid;
        mapping(uint32 srcEid => mapping(bytes32 sender => uint64 nonce)) maxReceivedNonce;
        bool orderedNonce;
        // for global assertions
        mapping(uint32 srcEid => uint256 count) inboundCount;
        mapping(uint32 dstEid => uint256 count) outboundCount;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.omnicounterabstract")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = 0x077b97a8aca79405ec58163a260b303a7e7903026c7db58eeb101ceece6c4900;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}