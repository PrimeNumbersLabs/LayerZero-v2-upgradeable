// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import { PreCrimePeer } from "../interfaces/IPreCrimeUpgradeable.sol";


library PreCrimeStorage {
    struct Layout {
        // preCrime config
        uint64 maxBatchSize;
        PreCrimePeer[] preCrimePeers;
        address lzEndpoint;
        address simulator;
        address oApp;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.precrime")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_LOCATION =
        0x480d514d38955dc07fd3953b01fc0be91fc4d23c84aa64616ba3eb9a7738e300;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_LOCATION
        }
    }
}