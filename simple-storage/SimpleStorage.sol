// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

contract SimpleStorage {
    uint256 favoriteNumber; // storage variable

    struct Person {
        uint256 favoriteNumber;
        string name;
    }

    Person[] public listOfPeople;
    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public{
        favoriteNumber = _favoriteNumber;
    }

    // memory: temp vars that can be modified
    // callback: temp vars that can't be modified
    // storage: perm var that can be modified
    function addPerson(string calldata _name, uint256 _favoriteNumber) public {
        listOfPeople.push(Person(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }

    function retrieve() public view returns(uint256){
        return favoriteNumber;
    }
}