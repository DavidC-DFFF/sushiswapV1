// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/math/SafeMath.sol";
//import "./tokenlistv2.sol";
import "./whitelist.sol";
import "./yieldMaker-sushi.sol";
import "./assolist.sol";

abstract contract Vault is
    Ownable,
    //Tokenlist,
    Whitelist,
    YieldMaker
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

    /* address payable public router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    address public masterchef = 0xB3E32e6Df154ccE38c545d2FD16c43D1D6981247;
    address public sushi = 0x0769fd68dFb93167989C6f7254cd0D766Fb2841F;
    address public slp = 0x2205d8f2bd0D127E4fE4159892Fe8d785B3Ab095;
    address public token0 = 0x150d9A8b8b5DCf72CFabE303DAD915BD72B31D00; //- jEUR
    address public token1 = 0xC1B34a591C935156C7AAE685Eb68C6d7980a98FD; //- EURs*/

    constructor(
        address _yieldMaker,
        address _assolist
    ) public {
        assolist = _assolist;
        yieldMaker = _yieldMaker;
    }

    //change la liste de asso et de yieldmaker
    function changeAdresses(address _yieldMaker, address _assolist) public onlyOwner {
        if(_yieldMaker == address(0)) { yieldMaker = _yieldMaker;}
        if(_assolist == address(0)) { assolist = _assolist;}
    }

    // call yieldmaker for deposit to yield
    function O1_deposit(address _yieldMakerAddress, address _asset, uint256 _amount)
        public
        isWhitelisted(_asset)
    {   
        // Approve asset first
        ERC20(_asset).transferFrom(msg.sender, address(this));
        Balances[msg.sender][_asset] += _amount;
        // ERC20 is on vault;
        address _user = msg.sender;
        ERC20(_asset).approve(_yieldMakerAddress, _amount);     
        YieldMaker(_yieldMakerAddress).depositToYield(
            //_user,
            _asset, 
            _amount
        );
    }

    // call yieldmaker for withdraw from yield
    function O2_withdraw(address _yieldMakerAddress, address _asset, uint256 _amount) 
        public
        isWhitelisted(_asset)
    {
        require(
            _amount <= Balances[msg.sender][_asset],
            "Not enough funds"
        );
        address _user = msg.sender;
        Balances[msg.sender][_asset] -= _amount;
        YieldMaker(_yieldMakerAddress).withdrawFromYield(_user/*, _asset, _amount*/);
        // Manuel to test //_sushiToAsso();
    }
    
    function getBalance(address _asset) public view returns (uint256) {
        return Balances[msg.sender][_asset];
    }

    function giveToAsso(address _asso) public {

    }
    
    function O3_sushiToAsso() public {
        //address _spender = address(this);
        uint256 _amount = ERC20(sushi).balanceOf(address(this));
        /*ERC20(sushi).approve(
            _spender,
            _amount
        );*/
        ERC20(sushi).transfer(
            asso,
            _amount
        );
    }
}
