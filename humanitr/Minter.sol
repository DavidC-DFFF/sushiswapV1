// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./KarmaToken.sol";

contract Minter is Ownable {
    address vault;
    address karma;

    constructor(address _vault, address _karma) {
        vault = _vault;
        karma = _karma;
    }

    function setVault(address _vault) public onlyOwner {
        vault = _vault;
    }

    function mintKarma(uint256 _amount, address _user) public onlyVault {
        Karma(karma).mint(_user, _amount);
    }

    modifier onlyVault() {
        require (msg.sender == vault);
        _;
    }
}