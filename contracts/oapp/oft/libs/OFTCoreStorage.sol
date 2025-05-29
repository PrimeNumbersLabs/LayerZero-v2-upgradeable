// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { OAppUpgradeable, Origin } from "../oapp/OAppUpgradeable.sol";
import { OAppOptionsType3 } from "../oapp/libs/OAppOptionsType3.sol";
import { IOAppMsgInspector } from "../oapp/interfaces/IOAppMsgInspector.sol";

import { OAppPreCrimeSimulatorUpgradeable } from "../precrime/OAppPreCrimeSimulatorUpgradeable.sol";

import { IOFTUpgradeable, SendParam, OFTLimit, OFTReceipt, OFTFeeDetail, MessagingReceipt, MessagingFee } from "./interfaces/IOFTUpgradeable.sol";
import { OFTMsgCodec } from "./libs/OFTMsgCodec.sol";
import { OFTComposeMsgCodec } from "./libs/OFTComposeMsgCodec.sol";

/**
 * @title OFTCoreUpgradeable
 * @dev Abstract contract for the OftChain (OFT) token.
 */
library OFTCoreStorage {

    struct Layout {
        address msgInspector; // Address of the optional message inspector contract
        // @notice Provides a conversion rate when swapping between denominations of SD and LD
        //      - shareDecimals == SD == shared Decimals
        //      - localDecimals == LD == local decimals
        // @dev Considers that tokens have different decimal amounts on various chains.
        // @dev eg.
        //  For a token
        //      - locally with 4 decimals --> 1.2345 => uint(12345)
        //      - remotely with 2 decimals --> 1.23 => uint(123)
        //      - The conversion rate would be 10 ** (4 - 2) = 100
        //  @dev If you want to send 1.2345 -> (uint 12345), you CANNOT represent that value on the remote,
        //  you can only display 1.23 -> uint(123).
        //  @dev To preserve the dust that would otherwise be lost on that conversion,
        //  we need to unify a denomination that can be represented on ALL chains inside of the OFT mesh
        uint256 decimalConversionRate;
    }


    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.oftcore")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = 0xcdf163d3f8e25283aa6e6b65bf54c91efea10d39ab5536a331f79fb680ac7600;

    function layout() internal pure returns (Layout storage l) {
        assembly {
            l.slot := STORAGE_SLOT
        }
    }
}
