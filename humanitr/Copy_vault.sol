// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./whitelist.sol";
import "./yieldMaker-aave.sol";
import "./assolist.sol";

contract Vault is
    Ownable,
    Whitelist
{
    address aUSDC = 0x1Ee669290939f8a8864497Af3BC83728715265FF;
    mapping(address => mapping(address => uint256)) Balances;
    uint256 public totalAmount;
    address public asso = 0x54C470f15f3f34043BB58d3FBB85685B39E33ed8;
    address public yieldMaker;
    address public pool = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;

    constructor(address _yieldMaker) public {
        yieldMaker = _yieldMaker;
    }
    
    // set yieldMaker address for evo
    function setYieldMaker(address _yieldMaker) public onlyOwner {
        yieldMaker = _yieldMaker;
    }
    // call yieldmaker for deposit to yield
    function O1_deposit(address _asset, uint256 _amount)
        public
        isWhitelisted(_asset)
    {
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);
        Balances[msg.sender][_asset] += _amount;
        totalAmount += _amount;
        IERC20(_asset).transfer(yieldMaker, _amount);
        YieldMaker(yieldMaker).depositToYield(
            _asset,
            _amount
        );
    }
    // call yieldmaker for withdraw from yield
/*    function O2_withdraw(address _asset, uint256 _amount) 
        public
        isWhitelisted(_asset)
    {
        require(
            _amount <= Balances[msg.sender][_asset],
            "Not enough funds"
        );
        step1();
        uint256 _aToken = IERC20(aUSDC).balanceOf(address(this));
        step2(_aToken, _amount, totalAmount);
        uint256 _withdrawAmount = SafeMath.div(SafeMath.mul(_aToken, _amount), totalAmount);
        step3(_withdrawAmount);
        IERC20(aUSDC).transfer(yieldMaker, _withdrawAmount);
        step4(_asset, _withdrawAmount);
        YieldMaker(yieldMaker).withdrawFromYield(
            _asset,
            _withdrawAmount
        );
        // transfer
        step5();
        return IERC20(_asset).balanceOf(address(this));
        step6();
        IERC20(_asset).transfer(msg.sender, _amount);
        step7();
        Balances[msg.sender][_asset] -= _amount;
        step8();
        totalAmount -= _amount;
        step9();
        uint256 _rest = SafeMath.sub(_withdrawAmount, _amount);
        giveToAsso(asso, _asset, _rest);
    }*/

    address public asset;
    uint256 public amount;

    function step0(address _asset, uint256 _amount) public {
        asset = _asset;
        amount = _amount;   
    }

    uint256 public aToken;

    function step1() public returns (uint256) {
        aToken = IERC20(aUSDC).balanceOf(address(this));
        return aToken;
    }

    uint256 public withdrawAmount;

    function step2() public returns (uint256) {
        withdrawAmount = SafeMath.div(SafeMath.mul(aToken, amount), totalAmount);
        return withdrawAmount;
    }

    function step3() public returns (string memory) {
        IERC20(aUSDC).transfer(yieldMaker, withdrawAmount);
        return "OK !";
    }

    function step4() public {
        YieldMaker(yieldMaker).withdrawFromYield(
            asset,
            withdrawAmount
        );
    }

    function step5() public view returns (uint256) {
        return IERC20(asset).balanceOf(address(this));
    }

    function step6() public {
        IERC20(asset).transfer(msg.sender, amount);
    }
    
    function step7() public returns (uint256) {
        Balances[msg.sender][asset] -= amount;
        return Balances[msg.sender][asset];
    }

    function step8() public returns (uint256) {
        totalAmount -= amount;
        return totalAmount;
    }

    uint256 rest;

    function step9() public returns (uint256) {
        rest = SafeMath.sub(withdrawAmount, amount);
        return rest;
    }

    function step10() public {
        giveToAsso(asso, asset, rest);
    }

    // give to one wallet association
    function giveToAsso(address _asso, address _asset, uint256 _amount) public {
        IERC20(_asset).transfer(_asso, _amount);
    }
    // get the sender balance on the contract
    function getBalanceToken(address _asset) public view returns (uint256) {
        return Balances[msg.sender][_asset];
    }
    function getBalanceAAVEtoken() public view returns (uint256) {
        return IERC20(aUSDC).balanceOf(address(this));
    }
}