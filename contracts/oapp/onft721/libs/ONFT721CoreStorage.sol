// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

library ONFT721CoreStorage {

    struct Layout {
        address msgInspector; // Address of the optional message inspector contract
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.onft721core")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = 0x831bef63b5afbb472ffb0039f0027e0f8cb92dca0f265bddf9c795a7b4be6400;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}
