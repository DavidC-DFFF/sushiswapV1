// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/math/SafeMath.sol";
//import "./tokenlistv2.sol";
import "./whitelist.sol";
import "../sushiswap/contracts/MasterChef.sol";
import "../sushiswap/contracts/uniswapv2/UniswapV2Router02.sol";
import "../sushiswap/contracts/uniswapv2/UniswapV2Pair.sol";

contract Vault is
    Ownable,
    //Tokenlist,
    Whitelist
{
    // [wallet][token] => quantity
    mapping(address => mapping(address => uint256)) Balances;
    //wallets assos multiples
    //mapping(uint256 => address) assoWallets;
    address public asso = 0x54C470f15f3f34043BB58d3FBB85685B39E33ed8;

    address payable public router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    address public masterchef = 0xB3E32e6Df154ccE38c545d2FD16c43D1D6981247;
    address public sushi = 0x0769fd68dFb93167989C6f7254cd0D766Fb2841F;
    address public slp = 0x2205d8f2bd0D127E4fE4159892Fe8d785B3Ab095;
    address public token0 = 0x150d9A8b8b5DCf72CFabE303DAD915BD72B31D00; //- jEUR
    address public token1 = 0xC1B34a591C935156C7AAE685Eb68C6d7980a98FD; //- EURs

    constructor(
        /*
        //address _router,
        //address _slp,
        //address _masterchef,
        //address _asso,
        //address _token0
        //address _token1,
        //address _sushi
        //MasterChef _masterchef,
        //SushiToken _sushi
        */
    ) public {
        //router = _router;
        //slp = _slp;
        //masterchef = _masterchef;
        //asso = _asso;
        //token0 = _token0;
        //token1 = _token1;
        //sushi = _sushi;
        //masterchef = _masterchef;
        //sushi = _sushi;
    }

    function deposit(address _tokenAddress, uint256 _amount)
        public
        isWhitelisted(_tokenAddress)
        returns (uint256)
    {
        address _user = msg.sender;
        ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        Balances[msg.sender][_tokenAddress] += _amount;

        _swapHalf(_amount, _tokenAddress, _user);
        _assetsToSlp(_user);
        _slpToMasterchef();
    }

    function depositAave() public {
        
    }

    function withdrawAave() public {

    }
    function withdrawAll (/*address _tokenAddress, */address _user) public {        //supprimer tokenAddress
        _masterchefToSlp();
        _slpToUser(_user);
        // _slpToVault();
        // _swapBack();
        _sushiToAsso();
    }
    /* getAmountOut for 50%
    Approve to router for swap
    Swap 50% amount */
    function _swapHalf(
        uint256 _amount, 
        address _tokenAddress, 
        address _user                       //**************************Retirer address car SLP reste sur vault
    ) internal {
        uint256 _amountIn = SafeMath.div(_amount, 2);
        (uint112 reserve1, uint112 reserve2, ) = UniswapV2Pair(slp).getReserves();
        uint256 _amountOut = UniswapV2Router02(router).getAmountOut(
            _amountIn,
            reserve1,
            reserve2
        );
        uint256 _amountOutMin = SafeMath.div(SafeMath.mul(_amountOut, 9), 10);
        ERC20(_tokenAddress).approve(router, _amountIn);
        address[] memory _path;
        _path = new address[](2);
        _path[0] = token0;
        _path[1] = token1;

        uint256 _deadline = now + 120; // + 2 minutes
        UniswapV2Router02(router).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            _path,
            address(this),
            _deadline
        );
        Balances[_user][token1] += ERC20(token1).balanceOf(address(this));
        Balances[_user][token0] -= _amountIn;
    }
    function _assetsToSlp(address _user) internal {
        //LP to pair via router
        uint256 _amountADesired = ERC20(token0).balanceOf(address(this));
        uint256 _amountBDesired = ERC20(token1).balanceOf(address(this));
        ERC20(token0).approve(router, _amountADesired);
        ERC20(token1).approve(router, _amountBDesired);
        address _tokenA = token0;
        address _tokenB = token1;
        uint256 _amountAMin = SafeMath.div(SafeMath.mul(_amountADesired, 9), 10);
        uint256 _amountBMin = SafeMath.div(SafeMath.mul(_amountBDesired, 9), 10);
        address _to = address(this);
        uint256 _deadline = now + 120; // + 2 minutes
        UniswapV2Router02(router).addLiquidity(
            _tokenA,
            _tokenB,
            _amountADesired,
            _amountBDesired,
            _amountAMin,
            _amountBMin,
            _to,
            _deadline
        );
        Balances[_user][slp] += ERC20(slp).balanceOf(address(this));
        Balances[_user][token0] = ERC20(token0).balanceOf(address(this));
        Balances[_user][token1] = ERC20(token1).balanceOf(address(this));
    }
    function slpToAssets() public {
    }
    function _slpToMasterchef() internal {
        //approve slp to masterchef
        uint256 _value = ERC20(slp).balanceOf(address(this));
        ERC20(slp).approve(
            masterchef,
            _value
            );
        //Pool 0 = jEUR-EURs
        uint256 _pid = 0;
        uint256 _amount = _value;
        //deposit slp to masterchef
        MasterChef(masterchef).deposit(_pid, _amount);
    }
    function _masterchefToSlp() internal {
        //valeur du wallet dans pool 0
        uint256 _pid = 0;
        address _vault = address(this);
        (uint256 _amount, ) = MasterChef(masterchef).userInfo(_pid, _vault);
        MasterChef(masterchef).withdraw(_pid, _amount);
    }
    function _slpToUser(address _user) internal {
        //approve slp to router
        uint256 _value = ERC20(slp).balanceOf(address(this));
        ERC20(slp).approve(
            router,
            _value
            );
        address _tokenA = token0;
        address _tokenB = token1;
        uint256 _liquidity = _value;
        uint256 _amountAMin = SafeMath.div(SafeMath.mul(SafeMath.div(_liquidity, 2), 5), 10);
        uint256 _amountBMin = SafeMath.div(SafeMath.mul(SafeMath.div(_liquidity, 2), 5), 10);
        address _to = _user;
        //address _to = address(this);
        uint256 _deadline = now + 120; // + 2 minutes

        UniswapV2Router02(router).removeLiquidity(
            _tokenA,
            _tokenB,
            _liquidity,
            _amountAMin,
            _amountBMin,
            _to,
            _deadline
        );
    }
    function _swapBack() public {
    }
    function _sushiToAsso() public {
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
    function depositAll(address _tokenAddress) external {
        uint256 _amount = ERC20(_tokenAddress).balanceOf(msg.sender);
        ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        Balances[msg.sender][_tokenAddress] += _amount;
    }
    function withdraw(uint256 _amount, address _tokenAddress) public {
        require(
            _amount <= Balances[msg.sender][_tokenAddress],
            "Not enough funds"
        );
        ERC20(_tokenAddress).transfer(msg.sender, _amount);
        Balances[msg.sender][_tokenAddress] -= _amount;
    }
    function withdrawEmergency() external onlyOwner {
        ERC20(token0).transfer(
            msg.sender,
            ERC20(token0).balanceOf(address(this))
        );
        Balances[msg.sender][token0] = 0;
        ERC20(token1).transfer(
            msg.sender,
            ERC20(token1).balanceOf(address(this))
        );
        Balances[msg.sender][token1] = 0;
        ERC20(slp).transfer(
            msg.sender,
            ERC20(slp).balanceOf(address(this))
        );
    }
}
