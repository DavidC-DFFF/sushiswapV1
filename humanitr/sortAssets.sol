// SPDX-License-Identifier: dvdch.eth
// pragma solidity ^0.8.4;
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/access/Ownable.sol";

contract Assolist is Ownable {
   address[] public list;

   constructor() public {
      list.push(0x54C470f15f3f34043BB58d3FBB85685B39E33ed8);
   }

   function newAsso(address _newAsso) external onlyOwner {
      for (uint i = 0 ; i < list.length ; i++) {
         if (list[i] == _newAsso) { revert("Already in list"); }
      }
      list.push(_newAsso);
   }
   function deleteAsso(address _badAsso) external onlyOwner {
      for (uint i = 0 ; i < list.length ; i++) {
         if (list[i] == _badAsso) {
               list[i] = list[list.length - 1];
               list.pop();
         }
      }
   }

   modifier isAssoListed(address _asso) {
      require((list.length > 0), "No list for now");
      bool _assoListed = false;
      for (uint i = 0 ; i < list.length ; i++) {
         if ( _asso == list[i]) {
               _assoListed = true;
         }
      }
      require(_assoListed);
      _;
   }
}