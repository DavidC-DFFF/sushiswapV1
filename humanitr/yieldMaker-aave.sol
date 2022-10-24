// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/pool/Pool.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/tokenization/AToken.sol";

contract YieldMaker {
    address pool = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;
    address USDC = 0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43;
    address aUSDC = 0x1Ee669290939f8a8864497Af3BC83728715265FF;
    // deposit function to AAVE
    function depositToYield(
        address _asset, 
        uint256 _amount
    ) public {
        IERC20(_asset).approve(pool, _amount);
        Pool(pool).supply(
            _asset,
            _amount,
            msg.sender,
            0
        );
    }
    // withdraw function from AAVE
    function withdrawFromYield(
        address _asset, 
        uint256 _amount
    ) public {
        IERC20(_asset).approve(pool, _amount);
        Pool(pool).withdraw(
            _asset,
            _amount,
            msg.sender
        );
    }
}