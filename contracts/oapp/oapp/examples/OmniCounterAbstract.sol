// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ILayerZeroEndpointV2, MessagingFee, MessagingReceipt, Origin } from "../../../protocol/interfaces/ILayerZeroEndpointV2.sol";
import { ILayerZeroComposer } from "../../../protocol/interfaces/ILayerZeroComposer.sol";
import { OAppUpgradeable } from "../OAppUpgradeable.sol";
import { OptionsBuilder } from "../libs/OptionsBuilder.sol";
import { OAppPreCrimeSimulatorUpgradeable } from "../../precrime/OAppPreCrimeSimulatorUpgradeable.sol";

library MsgCodec {
    uint8 internal constant VANILLA_TYPE = 1;
    uint8 internal constant COMPOSED_TYPE = 2;
    uint8 internal constant ABA_TYPE = 3;
    uint8 internal constant COMPOSED_ABA_TYPE = 4;

    uint8 internal constant MSG_TYPE_OFFSET = 0;
    uint8 internal constant SRC_EID_OFFSET = 1;
    uint8 internal constant VALUE_OFFSET = 5;

    function encode(uint8 _type, uint32 _srcEid) internal pure returns (bytes memory) {
        return abi.encodePacked(_type, _srcEid);
    }

    function encode(uint8 _type, uint32 _srcEid, uint256 _value) internal pure returns (bytes memory) {
        return abi.encodePacked(_type, _srcEid, _value);
    }

    function msgType(bytes calldata _message) internal pure returns (uint8) {
        return uint8(bytes1(_message[MSG_TYPE_OFFSET:SRC_EID_OFFSET]));
    }

    function srcEid(bytes calldata _message) internal pure returns (uint32) {
        return uint32(bytes4(_message[SRC_EID_OFFSET:VALUE_OFFSET]));
    }

    function value(bytes calldata _message) internal pure returns (uint256) {
        return uint256(bytes32(_message[VALUE_OFFSET:]));
    }
}

// @dev declared as abstract to provide backwards compatibility with Oz5/Oz4
abstract contract OmniCounterAbstract is ILayerZeroComposer, OAppUpgradeable, OAppPreCrimeSimulatorUpgradeable {
    using MsgCodec for bytes;
    using OptionsBuilder for bytes;

    struct OmniCounterAbstractStorage {
        uint256 count;
        uint256 composedCount;
        address admin;
        uint32 eid;
        mapping(uint32 srcEid => mapping(bytes32 sender => uint64 nonce)) maxReceivedNonce;
        bool orderedNonce;
        // for global assertions
        mapping(uint32 srcEid => uint256 count) inboundCount;
        mapping(uint32 dstEid => uint256 count) outboundCount;
    }

    // keccak256(abi.encode(uint256(keccak256("primefi.layerzero.storage.omnicounterabstract")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OmniCounterAbstractStorageLocation = 0x077b97a8aca79405ec58163a260b303a7e7903026c7db58eeb101ceece6c4900;

    function _getOmniCounterAbstractStorage() internal pure returns (OmniCounterAbstractStorage storage ds) {
        assembly {
            ds.slot := OmniCounterAbstractStorageLocation
        }
    }

    function __OmniCounterAbstract_init(address _endpoint, address _delegate) internal onlyInitializing {
        __OApp_init(_endpoint, _delegate);
        __OAppPreCrimeSimulator_init();
        __OmniCounterAbstract_init_unchained(_endpoint);
    }

    function __OmniCounterAbstract_init_unchained(address _endpoint) internal onlyInitializing {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        $.admin = msg.sender;
        $.eid = ILayerZeroEndpointV2(_endpoint).eid();
    }

    modifier onlyAdmin() {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        require(msg.sender == $.admin, "only admin");
        _;
    }

    function inboundCount(uint32 _srcEid) external view returns (uint256) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        return $.inboundCount[_srcEid];
    }

    function outboundCount(uint32 _dstEid) external view returns (uint256) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        return $.outboundCount[_dstEid];
    }

    function count() external view returns (uint256) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        return $.count;
    }

    function composedCount() external view returns (uint256) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        return $.composedCount;
    }

    function admin() external view returns (address) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        return $.admin;
    }

    function eid() external view returns (uint32) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        return $.eid;
    }

    // -------------------------------
    // Only Admin
    function setAdmin(address _admin) external onlyAdmin {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        $.admin = _admin;
    }

    function withdraw(address payable _to, uint256 _amount) external onlyAdmin {
        (bool success, ) = _to.call{ value: _amount }("");
        require(success, "OmniCounter: withdraw failed");
    }

    // -------------------------------
    // Send
    function increment(uint32 _eid, uint8 _type, bytes calldata _options) external payable {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        //        bytes memory options = combineOptions(_eid, _type, _options);
        _lzSend(_eid, MsgCodec.encode(_type, $.eid), _options, MessagingFee(msg.value, 0), payable(msg.sender));
        _incrementOutbound(_eid);
    }

    // this is a broken function to skip incrementing outbound count
    // so that preCrime will fail
    function brokenIncrement(uint32 _eid, uint8 _type, bytes calldata _options) external payable onlyAdmin {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        //        bytes memory options = combineOptions(_eid, _type, _options);
        _lzSend(_eid, MsgCodec.encode(_type, $.eid), _options, MessagingFee(msg.value, 0), payable(msg.sender));
        // _incrementOutbound(_eid); // mock method which intentionally does not increment outboundCount to cause a PreCrime Crime
    }

    function batchIncrement(
        uint32[] calldata _eids,
        uint8[] calldata _types,
        bytes[] calldata _options
    ) external payable {
        require(_eids.length == _options.length && _eids.length == _types.length, "OmniCounter: length mismatch");
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        MessagingReceipt memory receipt;
        uint256 providedFee = msg.value;
        for (uint256 i = 0; i < _eids.length; i++) {
            address refundAddress = i == _eids.length - 1 ? msg.sender : address(this);
            uint32 dstEid = _eids[i];
            uint8 msgType = _types[i];
            //            bytes memory options = combineOptions(dstEid, msgType, _options[i]);
            receipt = _lzSend(
                dstEid,
                MsgCodec.encode(msgType, $.eid),
                _options[i],
                MessagingFee(providedFee, 0),
                payable(refundAddress)
            );
            _incrementOutbound(dstEid);
            providedFee -= receipt.fee.nativeFee;
        }
    }

    // -------------------------------
    // View
    function quote(
        uint32 _eid,
        uint8 _type,
        bytes calldata _options
    ) public view returns (uint256 nativeFee, uint256 lzTokenFee) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        //        bytes memory options = combineOptions(_eid, _type, _options);
        MessagingFee memory fee = _quote(_eid, MsgCodec.encode(_type, $.eid), _options, false);
        return (fee.nativeFee, fee.lzTokenFee);
    }

    // @dev enables preCrime simulator
    // @dev routes the call down from the OAppPreCrimeSimulator, and up to the OApp
    function _lzReceiveSimulate(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal virtual override {
        _lzReceive(_origin, _guid, _message, _executor, _extraData);
    }

    // -------------------------------
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        _acceptNonce(_origin.srcEid, _origin.sender, _origin.nonce);
        uint8 messageType = _message.msgType();
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        OAppCoreStorage storage oApp$ = _getOAppCoreStorage();
        if (messageType == MsgCodec.VANILLA_TYPE) {
            $.count++;

            //////////////////////////////// IMPORTANT //////////////////////////////////
            /// if you request for msg.value in the options, you should also encode it
            /// into your message and check the value received at destination (example below).
            /// if not, the executor could potentially provide less msg.value than you requested
            /// leading to unintended behavior. Another option is to assert the executor to be
            /// one that you trust.
            /////////////////////////////////////////////////////////////////////////////
            require(msg.value >= _message.value(), "OmniCounter: insufficient value");

            _incrementInbound(_origin.srcEid);
        } else if (messageType == MsgCodec.COMPOSED_TYPE || messageType == MsgCodec.COMPOSED_ABA_TYPE) {
            $.count++;
            _incrementInbound(_origin.srcEid);
            oApp$.endpoint.sendCompose(address(this), _guid, 0, _message);
        } else if (messageType == MsgCodec.ABA_TYPE) {
            $.count++;
            _incrementInbound(_origin.srcEid);

            // send back to the sender
            _incrementOutbound(_origin.srcEid);
            bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 10);
            _lzSend(
                _origin.srcEid,
                MsgCodec.encode(MsgCodec.VANILLA_TYPE, $.eid, 10),
                options,
                MessagingFee(msg.value, 0),
                payable(address(this))
            );
        } else {
            revert("invalid message type");
        }
    }

    function _incrementInbound(uint32 _srcEid) internal {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        $.inboundCount[_srcEid]++;
    }

    function _incrementOutbound(uint32 _dstEid) internal {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        $.outboundCount[_dstEid]++;
    }

    function lzCompose(
        address _oApp,
        bytes32 /*_guid*/,
        bytes calldata _message,
        address,
        bytes calldata
    ) external payable override {
        OAppCoreStorage storage oApp$ = _getOAppCoreStorage();
        require(_oApp == address(this), "!oApp");
        require(msg.sender == address(oApp$.endpoint), "!endpoint");
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        
        uint8 msgType = _message.msgType();
        if (msgType == MsgCodec.COMPOSED_TYPE) {
            $.composedCount += 1;
        } else if (msgType == MsgCodec.COMPOSED_ABA_TYPE) {
            $.composedCount += 1;

            uint32 srcEid = _message.srcEid();
            _incrementOutbound(srcEid);
            bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
            _lzSend(
                srcEid,
                MsgCodec.encode(MsgCodec.VANILLA_TYPE, $.eid),
                options,
                MessagingFee(msg.value, 0),
                payable(address(this))
            );
        } else {
            revert("invalid message type");
        }
    }

    // -------------------------------
    // Ordered OApp
    // this demonstrates how to build an app that requires execution nonce ordering
    // normally an app should decide ordered or not on contract construction
    // this is just a demo
    function setOrderedNonce(bool _orderedNonce) external onlyOwner {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        $.orderedNonce = _orderedNonce;
    }

    function _acceptNonce(uint32 _srcEid, bytes32 _sender, uint64 _nonce) internal virtual {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        mapping(uint32 => mapping(bytes32 => uint64)) storage maxReceivedNonce = $.maxReceivedNonce;

        uint64 currentNonce = maxReceivedNonce[_srcEid][_sender];
        if ($.orderedNonce) {
            require(_nonce == currentNonce + 1, "OApp: invalid nonce");
        }
        // update the max nonce anyway. once the ordered mode is turned on, missing early nonces will be rejected
        if (_nonce > currentNonce) {
            maxReceivedNonce[_srcEid][_sender] = _nonce;
        }
    }

    function nextNonce(uint32 _srcEid, bytes32 _sender) public view virtual override returns (uint64) {
        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        mapping(uint32 => mapping(bytes32 => uint64)) storage maxReceivedNonce = $.maxReceivedNonce;
        if ($.orderedNonce) {
            return maxReceivedNonce[_srcEid][_sender] + 1;
        } else {
            return 0; // path nonce starts from 1. if 0 it means that there is no specific nonce enforcement
        }
    }

    // TODO should override oApp version with added ordered nonce increment
    // a governance function to skip nonce
    function skipInboundNonce(uint32 _srcEid, bytes32 _sender, uint64 _nonce) public virtual onlyOwner {
        OAppCoreStorage storage oApp$ = _getOAppCoreStorage();
        oApp$.endpoint.skip(address(this), _srcEid, _sender, _nonce);

        OmniCounterAbstractStorage storage $ = _getOmniCounterAbstractStorage();
        if ($.orderedNonce) {
            $.maxReceivedNonce[_srcEid][_sender]++;
        }
    }

    function isPeer(uint32 _eid, bytes32 _peer) public view override returns (bool) {
        OAppCoreStorage storage $ = _getOAppCoreStorage();
        return $.peers[_eid] == _peer;
    }

    // @dev Batch send requires overriding this function from OAppSender because the msg.value contains multiple fees
    function _payNative(uint256 _nativeFee) internal virtual override returns (uint256 nativeFee) {
        if (msg.value < _nativeFee) revert NotEnoughNative(msg.value);
        return _nativeFee;
    }

    // be able to receive ether
    receive() external payable virtual {}

    fallback() external payable {}
}
