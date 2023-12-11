// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    HelperConfig public helperConfig;

    address public constant USER = address(1);
    uint256 public constant STARTING_USER_BALANCE = 10000 * 10 ** 18;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        (fundMe, helperConfig) = deploy.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testPriceFeedSetCorrectly() public {
        address retreivedPriceFeed = address(fundMe.getPriceFeed());
        // (address expectedPriceFeed) = helperConfig.activeNetworkConfig();
        address expectedPriceFeed = helperConfig.activeNetworkConfig();
        assertEq(retreivedPriceFeed, expectedPriceFeed);
    }

    function testMinimumDollarIs10() public {
        uint256 minimumDollar = 10 * 10 ** 18;
        assertEq(
            fundMe.MINIMUM_IN_USD(),
            minimumDollar,
            "Minimum dollar is 10"
        );
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4, "Version is 4");
    }

    function testFundFailsWithoutEnoughETH() public {
        // next line should revert
        vm.expectRevert();
        fundMe.fund(); // we don't send any ETH
    }

    function testFundUpdatesFunded() public {
        uint256 amount = 11 * 10 ** 18;

        vm.startPrank(USER); // the next tx will be sent by USER
        fundMe.fund{value: amount}();
        vm.stopPrank();

        assertEq(fundMe.getAddressToAmountFunded(address(USER)), amount);
    }
}
