// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

library OAppPreCrimeSimulatorStorage {
    struct Layout {
        // The address of the preCrime implementation.
        address preCrime;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.oappprecrimesimulator")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT =
        0x41cc82cee84fffdd1f933aa25ee29b9ef8f6f02e6e1fee0f86ecd08b727a8c00;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}