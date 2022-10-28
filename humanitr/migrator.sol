// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./donators.sol";

contract MigrateDonators is Ownable {
    struct profile {
        string name;
        mapping(address => mapping(address => uint256)) balancesByAssoByAsset;
        bool exists;
    }

    function migrate(address _oldDonators, address _newDonators) public onlyOwner {
        address[] memory _list = Donators2(_oldDonators).getDonatorsList();
        for (uint256 i = 0 ; i < _list.length ; i++ ) {
            Donators2(_newDonators).updateDonatorNameMigrate()
            Donators2(_newDonators).updateDonator
        }
    }
}