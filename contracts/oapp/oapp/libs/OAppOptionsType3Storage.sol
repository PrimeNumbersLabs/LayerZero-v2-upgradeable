// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

library OAppOptionsType3Storage {
    struct Layout {
        // @dev The "msgType" should be defined in the child contract.
        mapping(uint32 eid => mapping(uint16 msgType => bytes enforcedOption)) enforcedOptions;
    }

    bytes32 internal constant STORAGE_SLOT = keccak256("primefi.layerzero.storage.oappoptionstype3");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}