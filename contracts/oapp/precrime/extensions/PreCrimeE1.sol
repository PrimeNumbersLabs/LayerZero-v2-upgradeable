// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { Initializable } from "@solidstate/contracts/security/initializable/Initializable.sol";
import { ILayerZeroEndpoint } from "@layerzerolabs/lz-evm-v1-0.7/contracts/interfaces/ILayerZeroEndpoint.sol";
import { PreCrime } from "../PreCrime.sol";
import { PreCrimeStorage } from "../libs/PreCrimeStorage.sol";
import { PreCrimeE1Storage } from "../libs/PreCrimeE1Storage.sol";


abstract contract PreCrimeE1 is PreCrime, Initializable {
    using SafeCast for uint32;
    using PreCrimeStorage for PreCrimeStorage.Layout;
    using PreCrimeE1Storage for PreCrimeE1Storage.Layout;

    function initialize(
        address _lzEndpoint,
        address _simulator,
        uint32 _localEid
    ) external initializer {
        __PreCrime_init(_lzEndpoint, _simulator);
        __PreCrimeE1_init(_localEid);
    }

    function __PreCrimeE1_init(
        uint32 _localEid
    ) internal {
        PreCrimeE1Storage.Layout storage $ = PreCrimeE1Storage.layout();
        $.localEid = _localEid;
    }

    function _getLocalEid() internal view override returns (uint32) {
        PreCrimeE1Storage.Layout storage $ = PreCrimeE1Storage.layout();
        return $.localEid;
    }

    function _getInboundNonce(uint32 _srcEid, bytes32 _sender) internal view override returns (uint64) {
        PreCrimeStorage.Layout storage $ = PreCrimeStorage.layout();
        bytes memory path = _getPath(_srcEid, _sender);
        return ILayerZeroEndpoint($.lzEndpoint).getInboundNonce(_srcEid.toUint16(), path);
    }

    function _getPath(uint32 _srcEid, bytes32 _sender) internal view virtual returns (bytes memory);
}
