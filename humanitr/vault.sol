// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./whitelist.sol";
import "./yieldMaker-aave.sol";
import "./assolist.sol";

contract Vault is
    Ownable,
    Whitelist
{
    // [wallet][token] => quantity
    mapping(address => mapping(address => uint256)) Balances;

    // [wallet][assoWallet] => percentage of yield;
    // mapping(address => mapping(address => uint256)) Percentage;

    // wallets assos multiples
    // mapping(uint256 => address) asso;
    address public asso = 0x54C470f15f3f34043BB58d3FBB85685B39E33ed8;
    
    // Adresses for contracts for update
    address public assolist;
    address public yieldMaker;

    address public pool = 0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6;
    
    function setYieldMaker(address _yieldMaker) public onlyOwner {
        yieldMaker = _yieldMaker;
    }

    // call yieldmaker for deposit to yield
    function O1_deposit(address _asset, uint256 _amount)
        public
        isWhitelisted(_asset)
    {   
        // Approve asset first
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);
        Balances[msg.sender][_asset] += _amount;
        //IERC20(_asset).approve(pool, Balances[msg.sender][_asset]);
        //IERC20(_asset).transfer(yieldMaker, _amount);                         // test with transfer
        
        //IERC20(_asset).approve(yieldMaker, Balances[msg.sender][_asset]);
        IERC20(_asset).approve(pool, _amount);
        YieldMaker(yieldMaker).depositToYield(
            //_user,
            _asset,
            _amount
        );
    }

    // call yieldmaker for withdraw from yield
    function O2_withdraw(address _asset, uint256 _amount) 
        public
        isWhitelisted(_asset)
    {
        require(
            _amount <= Balances[msg.sender][_asset],
            "Not enough funds"
        );
        //address _user = address(this);
        uint256 _balance = Balances[msg.sender][_asset];
        YieldMaker(yieldMaker).withdrawFromYield(/*_user, */_asset, _amount, _balance);
        //transfer
        IERC20(_asset).transfer(msg.sender, _amount);
        Balances[msg.sender][_asset] -= _amount;
        //Manual giveToAsso(asso, _asset);
    }
    
    function getBalance(address _asset) public view returns (uint256) {
        return Balances[msg.sender][_asset];
    }

    function giveToAsso(address _asso, address _asset) public {
        uint256 _rest = IERC20(_asset).balanceOf(address(this));
        IERC20(_asset).transfer(_asso, _rest);
    }

    function reset() public onlyOwner {
        uint256 _reste = IERC20(0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43).balanceOf(address(this));
        IERC20(0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43).transfer(msg.sender, _reste);
        Balances[msg.sender][0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43] = 0;
    }
}
