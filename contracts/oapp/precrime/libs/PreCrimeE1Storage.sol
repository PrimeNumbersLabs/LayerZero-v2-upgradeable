// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

library PreCrimeE1Storage {
    struct Layout {
        uint32 localEid;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.precrime.e1")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.precrime.e1"))));

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}