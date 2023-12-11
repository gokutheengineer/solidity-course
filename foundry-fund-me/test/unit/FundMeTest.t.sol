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
    uint256 public constant SEND_AMOUNT = 11 * 10 ** 18;

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
        vm.startPrank(USER); // the next tx will be sent by USER
        fundMe.fund{value: SEND_AMOUNT}();
        vm.stopPrank();

        assertEq(fundMe.getAddressToAmountFunded(address(USER)), SEND_AMOUNT);
    }

    function testAddsFunderToFundersArray() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_AMOUNT}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_AMOUNT}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        uint256 initOwnerBalance = fundMe.getOwner().balance;
        uint256 initFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endFundMeBalance = address(fundMe).balance;

        assertEq(endFundMeBalance, 0);
        assertEq(endOwnerBalance, initOwnerBalance + initFundMeBalance);
    }
}
