// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./donators.sol";

/*
    struct profile {
        string name;
        address[] assets;
        address[] assos;
        mapping(address => mapping(address => uint256)) balancesByAssoByAsset;
        bool exists;
    }*/

contract MigrateDonators is Ownable {
    struct profile {
        string name;
        mapping(address => mapping(address => uint256)) balancesByAssoByAsset;
        bool exists;
    }

    function migrate(address _oldDonators, address _newDonators) public onlyOwner {
        address[] memory _walletList = Donators(_oldDonators).getDonatorsList();
        for (uint256 i = 0 ; i < _walletList.length ; i++ ) {
            //Name migrate
            Donators(_newDonators).updateDonatorName(Donators(_newDonators).DonatorProfile[_walletList[i]].name);
        }
    }
}