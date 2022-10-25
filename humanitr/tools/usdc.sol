// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.4;

// Address Goerli
// 0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract USDC is ERC20, Ownable, ERC20FlashMint {
    constructor() ERC20("USDC", "USDC") {
        _mint(msg.sender, 1000000 * 10 ** 6);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}