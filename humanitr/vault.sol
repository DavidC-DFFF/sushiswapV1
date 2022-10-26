// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./whitelist.sol";
import "./yieldMaker-aave.sol";
import { Associations } from "./associations.sol";

contract Vault is
    Ownable,
    Whitelist
{
// adresses declarations
    address aUSDC = 0x1Ee669290939f8a8864497Af3BC83728715265FF;
    // Balances[ sender ][ asset ][ asso ] = amount
    mapping(address => mapping(address => mapping(address => uint256))) Balances;
    //mapping(address => mapping(address => uint256)) Balances;
    uint256 totalAmount;
    address public asso = 0x54C470f15f3f34043BB58d3FBB85685B39E33ed8;
    address yieldMaker;
    address associations;
    address pool = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;

    uint256 public totalDonation;
// set constructor
    constructor (address _yieldMaker, address _associations) {
        yieldMaker = _yieldMaker;
        associations = _associations;
    }
// set yieldMaker address for evo
    function setYieldMaker(address _yieldMaker) public onlyOwner {
        yieldMaker = _yieldMaker;
    }
// set associations address for evo
    function setAssociations(address _associations) public onlyOwner {
        associations = _associations;
    }
// call yieldmaker for deposit to yield
    function O1_deposit(address _asset, uint256 _amount, address _asso)
        public
        isWhitelisted(_asset)
    {
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);
        //Associations(associations).updateDonation(_amount, _asso, msg.sender);
        Balances[msg.sender][_asset][_asso] += _amount;                         /////
        totalAmount += _amount;                                                 /////
        IERC20(_asset).transfer(yieldMaker, _amount);
        YieldMaker(yieldMaker).depositToYield(
            _asset,
            _amount
        );
    }
// call yieldmaker for withdraw from yield
    function O2_withdraw(address _asset, uint256 _amount, address _asso) 
        public
        isWhitelisted(_asset)
    {
        require(
            _amount <= Balances[msg.sender][_asset][_asso],
            //_amount <= Associations(associations).getUserDonation(msg.sender, _asso),
            "Not enough funds"
        );
        uint256 _aToken = IERC20(aUSDC).balanceOf(address(this));
        uint256 _withdrawAmount = SafeMath.div(SafeMath.mul(_aToken, _amount), totalAmount);
        IERC20(aUSDC).transfer(yieldMaker, _withdrawAmount);
        YieldMaker(yieldMaker).withdrawFromYield(
            _asset,
            _withdrawAmount
        );
        // transfer
        IERC20(_asset).transfer(msg.sender, _amount);

        Balances[msg.sender][_asset][_asso] -= _amount;
        totalAmount -= _amount;
        uint256 _rest = IERC20(_asset).balanceOf(address(this));
        Associations(associations).updateDonation(_rest, _asso, msg.sender);
        //totalDonation += _rest; ▼ replaced by ▼
        //getTotal from asso.sol
        giveToAsso(_asso, _asset, _rest);
    }
// withdraw all of asset for asso from msg.sender
    function O3_withdrall(address _asset, address _asso)
        public
        isWhitelisted(_asset)
    {
        uint256 _amount = Balances[msg.sender][_asset][_asso];
        O2_withdraw(
            _asset,
            _amount,
            _asso
        );
    }
// give to one wallet association
    function giveToAsso(address _asso, address _asset, uint256 _amount) internal {
        IERC20(_asset).transfer(_asso, _amount);
    }
// get the sender balance on the contract
    function getBalanceToken(address _asset, address _asso) public view returns (uint256) {
        return Balances[msg.sender][_asset][_asso];
    }
}