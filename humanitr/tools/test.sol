// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract test {

    function deposit(uint256 _amount) public {
        IERC20(0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43).transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw() public {
        uint256 _amount = IERC20(0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43).balanceOf(address(this));
        IERC20(0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43).transfer(msg.sender, _amount);
    }
}
