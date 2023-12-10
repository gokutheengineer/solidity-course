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

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        (fundMe, helperConfig) = deploy.run();
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
}
