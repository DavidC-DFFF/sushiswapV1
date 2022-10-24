// SPDX-License-Identifier: dvdch.eth
//pragma solidity ^0.6.0;
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

import "../aave/pool.sol";
import "../aave/aToken.sol";

contract YieldMaker {

    address public vault;

    address pool = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;

    address USDC = 0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43;
    address aUSDC = 0x1Ee669290939f8a8864497Af3BC83728715265FF;

    constructor(
        address _vault
    ) public {
        vault = _vault;
    }
    
    function depositToYield(
        //address _user, 
        address _asset, 
        uint256 _amount
    ) public {
        Pool(pool).supply(
            USDC,               //_asset,
            _amount,
            vault,                              // vault reçoit les USDC et les stake sur AAVE
            0                   //_referralCode
        );
    }

    function withdrawFromYield(address _user, address _asset, uint256 _amount, uint256 _balance) public {
        uint256 _aTokenAmount = AToken(aUSDC).balanceOf(_user);
        uint256 _amountAdjusted = (_amount.mul(_aTokenAmount)).div(_balance);
        Pool(pool).withdraw(
            _asset,
            _amountAdjusted,
            vault
        );
    }
}