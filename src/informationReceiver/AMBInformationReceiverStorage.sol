pragma solidity 0.6.7;

import "./interfaces/IHomeAMB.sol";

contract AMBInformationReceiverStorage {
    IHomeAMB public immutable bridge;

    enum Status {
        Unknown,
        Pending,
        Ok,
        Failed
    }

    mapping(bytes32 => Status) public status;

    event MessageStatus(bytes32 indexed messageId, Status status);

    constructor(IHomeAMB _bridge) public {
        bridge = _bridge;
    }

    function _setStatus(bytes32 _messageId, Status _status) internal {
        status[_messageId] = _status;
        emit MessageStatus(_messageId, _status);
    }
}