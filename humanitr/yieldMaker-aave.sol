// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;

// Goerli
// 0x7EDA38f11604bcF3419bA49663d31cabA32A7100

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/pool/Pool.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/tokenization/AToken.sol";

// Goerli address : 0xF57C4cc042ae0E1A9A134899d1151Cb6C8C0342A

contract YieldMaker is Ownable {
    address public pool = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;
    address public USDC = 0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43;
    address public aUSDC = 0x1Ee669290939f8a8864497Af3BC83728715265FF;
// update AAVE addresses
    function changeAaveAddresses(address _pool, address _aUSDC, address _USDC) public onlyOwner {
        pool = _pool;
        aUSDC = _aUSDC;
        USDC = _USDC;
    }
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