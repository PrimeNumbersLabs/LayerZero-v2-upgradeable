// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

library ONFT721AdapterStorage {
    struct Layout {
        IERC721 innerToken;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.onft721adapter")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = 0x11e0f117225a3dc9e19549ccf79cc9737461fce17edb3816e369f52c9f1b5100;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}