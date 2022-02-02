// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./XdaiRedemptionPriceSnap.sol";

contract XdaiRedemptionPriceSnapTest is DSTest {
    XdaiRedemptionPriceSnap snap;

    function setUp() public {
        snap = new XdaiRedemptionPriceSnap();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
