// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {SimpleStorage} from "SimpleStorage.sol";

contract AddFiveStorage is SimpleStorage {
    function store(uint _favoriteNumber) public override {
        favoriteNumber = _favoriteNumber + 5;
    }
}