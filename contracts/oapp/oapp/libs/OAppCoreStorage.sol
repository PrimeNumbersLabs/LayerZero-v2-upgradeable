// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import { ILayerZeroEndpointV2 } from "../interfaces/IOAppCore.sol";

library OAppCoreStorage {
    struct Layout {
        // The address of the LayerZero endpoint.
        ILayerZeroEndpointV2 endpoint;

        // Mapping to store peers associated with corresponding endpoints.
        mapping(uint32 eid => bytes32 peer) peers;
    }
    
    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.oappcore")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = 0x402bd74f7d455ec1741bc37d35d77af9bd887a72bbef52ccbcd544c85ab49200;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}