// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.10;

// Goerli : 0x989cD1Fe6cC17cf51cAE97389A884b88b46F8eaf

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
        
        
        
        