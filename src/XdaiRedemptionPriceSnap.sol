// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.7;

import "./informationReceiver/BasicAMBInformationReceiver.sol";

contract XdaiRedemptionPriceSnap is BasicAMBInformationReceiver {

    // Latest recorded redemption price
    uint256           public snappedRedemptionPrice;
    // mainnet redemptionPriceSnap address
    address immutable public mainnetRedemptionPriceSnap;
    // precomputed eth_call selector
    bytes32 immutable public ethCallSelector;

    // event new snap
    event UpdateSnappedRedemptionPrice(uint redemptionPrice);

    constructor(IHomeAMB _bridge, address _mainnetSnap) public AMBInformationReceiverStorage(_bridge) {
        mainnetRedemptionPriceSnap = _mainnetSnap;
        ethCallSelector = keccak256("eth_call(address,bytes)");
    }

    function requestSnappedPrice() external returns (bytes32 messageId) {
        bytes memory method = abi.encodeWithSelector(this.snappedRedemptionPrice.selector);
        bytes memory data = abi.encode(mainnetRedemptionPriceSnap, method);
        messageId = bridge.requireToGetInformation(ethCallSelector, data);
        _setStatus(messageId, Status.Pending);
    }

    function _unwrap(bytes memory _result) pure internal returns(bytes memory unwrapped_response) {
        unwrapped_response = abi.decode(_result, (bytes));
    }

    function onResultReceived(bytes32 /* _messageId */, bytes memory _result) internal override {
        bytes memory unwrapped = _unwrap(_result);
        require(unwrapped.length == 32, "invalid response");
        snappedRedemptionPrice = abi.decode(unwrapped, (uint256));
        emit UpdateSnappedRedemptionPrice(snappedRedemptionPrice);
    }
}