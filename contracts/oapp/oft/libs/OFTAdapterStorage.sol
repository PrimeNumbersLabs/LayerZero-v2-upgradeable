// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

library OFTAdapterStorage {
    
    struct Layout {
        IERC20 innerToken; // The underlying ERC20 token that this adapter wraps.
    }
    
    bytes32 internal constant STORAGE_SLOT = keccak256("primefi.layerzero.storage.oftadapter");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
