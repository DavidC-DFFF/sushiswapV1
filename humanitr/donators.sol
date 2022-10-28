// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Donators is Ownable {
    address public vault;
    address public migrator;
    address[] public donatorsList;
    struct profile {
        string name;
        mapping(address => mapping(address => uint256)) balancesByAssoByAsset;
        bool exists;
    }
    mapping(address => profile) public DonatorProfile;

    constructor(address _vault, address _migrator) {
        vault = _vault;
        migrator = _migrator;
    }

    function setVault(address _vault) public onlyOwner {
        vault = _vault;
    }

    function setMigrator(address _migrator) public onlyOwner {
        migrator = _migrator;
    }

    function setNewDonator(address _donator) public onlyVault {
        for (uint256 i; i < donatorsList.length; i++) {
            if (donatorsList[i] == _donator) {
                return;
            }
        }
        donatorsList.push(_donator);
        DonatorProfile[_donator].exists = true;
    }

    function updateDonatorMigrate (
        string memory _name,
        uint256 _amount,
        address _asset,
        address _assoWallet,
        address _userWallet
    ) public onlyMigrator {
        setNewDonator(_userWallet);
        DonatorProfile[_userWallet].balancesByAssoByAsset[_assoWallet][_asset] += _amount;
        DonatorProfile[_userWallet].name = _name;
    }

    function updateDonator(
        uint256 _amount,
        address _asset,
        address _assoWallet,
        address _userWallet
    ) public onlyVault {
        setNewDonator(_userWallet);
        DonatorProfile[_userWallet].balancesByAssoByAsset[_assoWallet][
                _asset
            ] += _amount;
    }

    function updateDonatorName(string memory _name) public {
        require(
            DonatorProfile[msg.sender].exists == true,
            "donator doesn't exist"
        );
        DonatorProfile[msg.sender].name = _name;
    }

/*    function getDonatorName(address _wallet)
        public
        view
        returns (string memory)
    {
        require(DonatorProfile[_wallet].exists, "Is not donator yet");
        string memory _name = DonatorProfile[_wallet].name;
        return _name;
    }*/

    function getDonatorAmounts(
        address _wallet,
        address _asso,
        address _asset
    ) public view returns (uint256) {
        require(DonatorProfile[_wallet].exists, "Is not donator yet");
        return DonatorProfile[_wallet].balancesByAssoByAsset[_asso][_asset];
    }

    function getDonatorsList() public view returns (address[] memory) {
        return donatorsList;
    }

    modifier onlyVault() {
        require(msg.sender == vault, "Only vault can do that");
        _;
    }
    
    modifier onlyMigrator() {
        require(msg.sender == migrator, "Only migrator can do that");
        _;
    }
}
