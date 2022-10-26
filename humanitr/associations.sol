// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Associations is Ownable {
    mapping(address => uint256) UserDonation;
    uint256 totalDonation;
    struct asso {
        address wallet;
        string name;
        uint256 donation;
    }
    asso[] public Assos;
    asso[] public OldAssos;
    address public vault;

    constructor(address _vaultAddress) {
        vault = _vaultAddress;
    }
    function declareAsso(address _wallet, string memory _name) public onlyOwner {
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _wallet) {
                revert("Asso already declared");
            }
        }
        asso memory _asso;
        _asso.wallet = _wallet;
        _asso.name = _name;
        _asso.donation = 0;
        Assos.push(_asso);
    }
    function deleteAsso(address _wallet) public onlyOwner {
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _wallet) {
                OldAssos.push(Assos[i]);
                Assos[i] = Assos[Assos.length - 1];
                Assos.pop();
            }
        }
    }
    function updateDonation(uint256 _amount, address _assoWallet) public assoActive(_assoWallet) {
        require ( vault == msg.sender );
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _assoWallet) {
                Assos[i].donation += _amount;
            }
        }
    }
    function getAssoDonation(address _assoWallet) public view assoExists(_assoWallet) returns(uint256)  {
        uint256 _donation;
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _assoWallet) {
                _donation = Assos[i].donation;
            }
        }
        return _donation;
    }
    function getFullDonation() public view returns(uint256) {
        uint256 _donation;
        for (uint i = 0 ; i < Assos.length ; i++) {
            _donation += Assos[i].donation;
        }
        for (uint i = 0 ; i < OldAssos.length ; i++) {
            _donation += OldAssos[i].donation;
        }
        return _donation;
    }
    modifier assoExists(address _asso) {
        bool _exist = false;
        for (uint i = 0 ; i < Assos.length ; i++) {
            if(Assos[i].wallet == _asso) {
                _exist = true;
            }
        }
        for (uint i = 0 ; i < OldAssos.length ; i++) {
            if(OldAssos[i].wallet == _asso) {
                _exist = true;
            }
        }
        require(_exist, "This asso has never been declared");
        _;
    }
    modifier assoActive(address _asso) {
        bool _active = false;
        for (uint i = 0 ; i < Assos.length ; i++) {
            if(Assos[i].wallet == _asso) {
                _active = true;
            }
        }
        require(_active, "This asso is not active");
        _;
    }
}