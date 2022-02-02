pragma solidity 0.6.7;

interface IAMBInformationReceiver {
    function onInformationReceived(bytes32 messageId, bool status, bytes calldata result) external;
}