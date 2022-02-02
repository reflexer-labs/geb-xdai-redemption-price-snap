// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.7;

import "ds-test/test.sol";
import "./XdaiRedemptionPriceSnap.sol";

contract Bridge {
    IAMBInformationReceiver requester;
    uint requestCount;

    function requireToGetInformation(bytes32 /* selector */, bytes memory /* data */) public returns (bytes32) {
        requester = IAMBInformationReceiver(msg.sender);
        return keccak256(abi.encodePacked(++requestCount));
    }

    function fireCallback(bool status, bytes memory result) public {
        requester.onInformationReceived(keccak256(abi.encodePacked(requestCount)), status, result);
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

    function test_request_callback(uint price) public {
        bytes32 messageId = snap.requestSnappedPrice();

        assertEq(uint(snap.status(messageId)), uint(Status.Pending));

        bridge.fireCallback(true, abi.encode(abi.encode(price)));

        assertEq(snap.snappedRedemptionPrice(), price);
        assertEq(uint(snap.status(messageId)), uint(Status.Ok));
    }
}
