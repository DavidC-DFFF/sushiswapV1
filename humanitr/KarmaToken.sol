// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Imports
    import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
    import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
    import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
//Contract
contract Karma is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {
    address public vault;

    function setVault(address _vault) public onlyOwner {
        vault = _vault;
    }
    constructor(address _vault) ERC20("Karma", "KRM") ERC20Permit("Karma") {
        _mint(msg.sender, 100000 * 10 ** decimals());
        vault = _vault;
    }

    function decimals() public view override returns (uint8) {
        return 6;
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function mint(address _to, uint256 _amount) public onlyVault {
        _mint(_to, _amount);
    }

    function burn(address _spender, uint256 _amount) public onlyVault {
        _burn(_spender, _amount);
    }

// The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
// Modifier
    modifier onlyVault() {
        require(msg.sender == vault);
        _;
    }
}
