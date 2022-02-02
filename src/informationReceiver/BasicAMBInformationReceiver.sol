pragma solidity 0.6.7;

import "./interfaces/IAMBInformationReceiver.sol";
import "./AMBInformationReceiverStorage.sol";

abstract contract BasicAMBInformationReceiver is IAMBInformationReceiver, AMBInformationReceiverStorage {
    function onInformationReceived(
        bytes32 _messageId,
        bool _status,
        bytes calldata _result
    ) external override {
        require(msg.sender == address(bridge), "invalid caller");
        require(status[_messageId] == Status.Pending, "invalid messageId");
        if (_status) {
            onResultReceived(_messageId, _result);
        }
        _setStatus(_messageId, _status ? Status.Ok : Status.Failed);
    }

    function onResultReceived(bytes32 _messageId, bytes memory _result) internal virtual;
}