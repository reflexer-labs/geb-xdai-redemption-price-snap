pragma solidity 0.6.7;
interface IHomeAMB {
    function requireToGetInformation(bytes32 _requestSelector, bytes calldata _data) external returns (bytes32);
}