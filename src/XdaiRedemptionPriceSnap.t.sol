// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.7;

import "ds-test/test.sol";
import "./XdaiRedemptionPriceSnap.sol";

contract Bridge {
    IAMBInformationReceiver requester;
    uint public requestCount;

    function requireToGetInformation(bytes32 /* selector */, bytes memory /* data */) public returns (bytes32) {
        requester = IAMBInformationReceiver(msg.sender);
        return keccak256(abi.encodePacked(++requestCount));
    }

    function fireCallback(bytes32 messageId, bool status, bytes memory result) public {
        requester.onInformationReceived(messageId, status, result);
    }
}

contract XdaiRedemptionPriceSnapTest is DSTest {
    XdaiRedemptionPriceSnap snap;
    Bridge bridge;
    address mainnetSnap = address(0xabc);

    enum Status {
        Unknown,
        Pending,
        Ok,
        Failed
    }

    function setUp() public {
        bridge = new Bridge();
        snap = new XdaiRedemptionPriceSnap(IHomeAMB(address(bridge)), mainnetSnap);
    }

    function test_setup() public {
        assertEq(snap.snappedRedemptionPrice(), 0);
        assertEq(snap.mainnetRedemptionPriceSnap(), address(mainnetSnap));
        assertEq(address(snap.bridge()), address(bridge));
    }

    function encodeUintBridgeResponse(uint redemptionPrice) pure internal returns (bytes memory) {
        return abi.encode(abi.encode(redemptionPrice));
    }

    function test_request_callback(uint price) public {
        bytes32 messageId = snap.requestSnappedPrice();

        assertEq(uint(snap.status(messageId)), uint(Status.Pending));

        bridge.fireCallback(messageId, true, encodeUintBridgeResponse(price));

        assertEq(snap.snappedRedemptionPrice(), price);
        assertEq(uint(snap.status(messageId)), uint(Status.Ok));
    }

    function testFail_callback_not_from_bridge(uint price) public {
        bytes32 messageId = snap.requestSnappedPrice();

        assertEq(uint(snap.status(messageId)), uint(Status.Pending));

        snap.onInformationReceived(messageId, true, encodeUintBridgeResponse(price));
    }

    function test_request_callback_failed(uint price) public {
        bytes32 messageId = snap.requestSnappedPrice();

        assertEq(uint(snap.status(messageId)), uint(Status.Pending));

        bridge.fireCallback(messageId, false, encodeUintBridgeResponse(price));

        assertEq(snap.snappedRedemptionPrice(), 0);
        assertEq(uint(snap.status(messageId)), uint(Status.Failed));
    }

    function testFail_callback_no_request(bytes32 messageId, uint price) public {
        bridge.fireCallback(messageId, true, encodeUintBridgeResponse(price));
    }

    function testFail_callback_twice(uint price) public {
        bytes32 messageId = snap.requestSnappedPrice();

        assertEq(uint(snap.status(messageId)), uint(Status.Pending));

        bridge.fireCallback(messageId, true, encodeUintBridgeResponse(price));
        bridge.fireCallback(messageId, true, encodeUintBridgeResponse(price));
    }

    function testFail_invalid_response_length() public {
        bytes32 messageId = snap.requestSnappedPrice();

        assertEq(uint(snap.status(messageId)), uint(Status.Pending));

        bridge.fireCallback(messageId, true, abi.encode("0x1"));
    }

    function test_request_callback_multiple(uint[5] memory prices) public {
        bytes32[5] memory messageIds;

        for (uint i = 0; i < 5; i++) {
            messageIds[i] = snap.requestSnappedPrice();
            assertEq(uint(snap.status(messageIds[i])), uint(Status.Pending));
        }

        for (uint i = 0; i < 5; i++) {
            bridge.fireCallback(messageIds[i], true, encodeUintBridgeResponse(prices[i]));

            assertEq(snap.snappedRedemptionPrice(), prices[i]);
            assertEq(uint(snap.status(messageIds[i])), uint(Status.Ok));
        }
    }
}
