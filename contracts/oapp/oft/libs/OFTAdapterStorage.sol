// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IERC20Metadata, IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IOFTUpgradeable, OFTCoreUpgradeable } from "./OFTCoreUpgradeable.sol";

library OFTAdapterStorage {
    
    struct Layout {
        IERC20 innerToken; // The underlying ERC20 token that this adapter wraps.
    }
    
    bytes32 internal constant STORAGE_SLOT = keccak256("primefi.layerzero.storage.oftadapter") - 1;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}
