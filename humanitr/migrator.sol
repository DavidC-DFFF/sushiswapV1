// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./donators.sol";

contract Migrator is Ownable {

    address public oldDonators;
    address public newDonators;

    
    address[] walletList;
    address[] assetsList;
    address[] assosList;

    function setOldDonators(address _old) public {
        oldDonators = _old;
    }

    function setNewDonator(address _new) public {
        newDonators = _new;
    }

    function migrate(/*address _oldDonators, address _newDonators*/) public onlyOwner {
        address _oldDonators = oldDonators;
        address _newDonators = newDonators;
//
        /*address[] memory _walletList;
        address[] memory _assetsList;
        address[] memory _assosList;*/

/*        //address[] memory _walletList = Donators(_oldDonators).getDonatorsList();
        for (uint256 i = 0 ; i < Donators(oldDonators).getDonatorsList().length ; i++ ) {
            //_walletList.push(Donators(oldDonators).getDonatorsList()[i]);
            _walletList[i] = Donators(oldDonators).getDonatorsList()[i];
        }
        //address[] memory _assetsList = Donators(_oldDonators).getAssetsList();
        for (uint256 i = 0 ; i < Donators(oldDonators).getAssetsList().length ; i++ ) {
            _assetsList[i] = Donators(oldDonators).getAssetsList()[i];
        }
        //address[] memory _assosList = Donators(_oldDonators).getAssosList();
        for (uint256 i = 0 ; i < Donators(oldDonators).getAssosList().length ; i++ ) {
            _assosList[i] = Donators(oldDonators).getAssosList()[i];
        }*/
//
        for (uint256 i = 0 ; i < Donators(oldDonators).getDonatorsList().length ; i++ ) {
            address _wallet = Donators(oldDonators).getDonatorsList()[i];
            string memory _name = Donators(_oldDonators).getDonatorName(_wallet);
            for (uint256 j = 0 ; j < Donators(oldDonators).getAssosList().length ; j++ ){
                address _asso = Donators(oldDonators).getAssosList()[j];
                for (uint256 k = 0 ; k < Donators(oldDonators).getAssetsList().length ; k++) {
                    Donators(_newDonators).updateDonatorMigrate(
                        _name,
                        Donators(_oldDonators).getDonatorAmounts(_wallet, _asso , Donators(oldDonators).getAssetsList()[k]),
                        Donators(oldDonators).getAssetsList()[k],
                        _asso,
                        _wallet
                    );
                }
            }
        }
    }
}

        
        
        
        
        