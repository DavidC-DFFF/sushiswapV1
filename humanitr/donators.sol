// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Donators is Ownable {

   address public vault;
   address[] public donators;
   

   constructor (address _vault) {
      vault = _vault;
   }

   function setVault(address _vault) public onlyOwner {
      vault = _vault;
   }

   function setNewDonator(address _donator) public onlyVault {
      for (uint256 i ; i < donators.length ; i++ ) {
         if ( donators[i] == _donator ) {
            return;
         }
      }
      donators.push(_donator);
   }

   function getDonatorsList() public view returns (address[] memory) {
        return donators;
   }

    modifier onlyVault() {
        require(msg.sender == vault, "Only vault can do that");
        _;
    }
}