// SPDX-License-Identifier: dvdch.eth
//pragma solidity ^0.6.0;
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/pool/Pool.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/tokenization/AToken.sol";

contract YieldMaker {

    address public vault;

    address pool = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;

    address USDC = 0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43;
    address aUSDC = 0x1Ee669290939f8a8864497Af3BC83728715265FF;

    function setVault(address _vault) public {
        vault = _vault;
    }
    
    function depositToYield(
        address _asset, 
        uint256 _amount
    ) public {
        //IERC20(_asset).approve(pool, _amount);   //
        Pool(pool).supply(
            _asset,
            _amount,
            msg.sender,             // pour test
            //vault,                // vault reçoit les USDC et les stake sur AAVE
            0                       //_referralCode
        );
    }

    function withdrawFromYield(
        //address _user, 
        address _asset, 
        uint256 _amount, 
        uint256 _balance
    ) public {
        uint256 _aTokenAmount = AToken(aUSDC).balanceOf(/*vault*/msg.sender);
        //uint256 _amountAdjusted = SafeMath.div(SafeMath.mul(_aTokenAmount, _amount), _balance);
        Pool(pool).withdraw(
            _asset,
            _aTokenAmount,     //_amountAdjusted,
            msg.sender              // pour test
            //vault                 // vault reçoit les USDC et les stake sur AAVE
        );
    }
}