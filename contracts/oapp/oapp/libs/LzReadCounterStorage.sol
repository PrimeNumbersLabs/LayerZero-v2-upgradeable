// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

library LzReadCounterStorage {
    struct Layout {
        uint256 count;
        uint32 eid;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.lzreadcounter")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant LzReadCounterStorageLocation = 0xff9d5fe0e5d16df304a8a1e0adecf6166c1a70835ffdf079de6b44823c9a8900;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := LzReadCounterStorageLocation
        }
    }
}