// SPDX-License-Identifier: dvdch.eth
pragma solidity ^0.8.10;

contract ReadDatas {
    // UserDonation[wallet][asso] = amount
    mapping(address => mapping(address => uint256)) public UserDonation;

    struct asso {
        address wallet;
        string name;
        uint256 donation;
    }
    asso[] public Assos;
    asso[] public OldAssos;
    address[] public asset;
    address public vault;
    
    constructor(address _vaultAddress) {
        vault = _vaultAddress;
        asso memory _asso;
        _asso.donation = 0;
        _asso.wallet = msg.sender;
        _asso.name = "Owner";
        Assos.push(_asso);
    }
    function setVault(address _vault) public onlyOwner {
        vault = _vault;
    }
    function declareAsso(address _wallet, string memory _name) public onlyOwner {
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _wallet) {
                revert("Asso already declared");
            }
        }
        asso memory _asso;
        _asso.donation = 0;
        _asso.wallet = _wallet;
        _asso.name = _name;
        for (uint i = 0 ; i < OldAssos.length ; i++) {
            if (OldAssos[i].wallet == _wallet) {
                _asso.donation = OldAssos[i].donation;
                _asso.wallet = OldAssos[i].wallet;
                _asso.name = OldAssos[i].name;
                OldAssos[i] = OldAssos[OldAssos.length - 1];
                OldAssos.pop();
            }
        }
        Assos.push(_asso);
    }
    function deleteAsso(address _wallet) public assoActive(_wallet) onlyOwner assoActive(_wallet) {
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _wallet) {
                OldAssos.push(Assos[i]);
                Assos[i] = Assos[Assos.length - 1];
                Assos.pop();
            }
        }
    }
    function updateDonation(uint256 _amount, address _assoWallet, address _userWallet) public onlyVault assoActive(_assoWallet) {
        require ( vault == msg.sender );
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _assoWallet) {
                Assos[i].donation += _amount;
            }
        }
        UserDonation[_userWallet][_assoWallet] += _amount;
    }
    function getAssoDonation(address _assoWallet) public view assoExists(_assoWallet) returns(uint256)  {
        uint256 _donation;
        for (uint i = 0 ; i < Assos.length ; i++) {
            if (Assos[i].wallet == _assoWallet) {
                _donation = Assos[i].donation;
            }
        }
        for (uint i = 0 ; i < OldAssos.length ; i++) {
            if (OldAssos[i].wallet == _assoWallet) {
                _donation = OldAssos[i].donation;
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
    function getUserDonation(address _user, address _asso) public view returns(uint256) {
        return UserDonation[_user][_asso];
    }
    function getUserFullDonation(address _user) public view returns(uint256) {
        uint256 _amount;
        for (uint256 i = 0 ; i < Assos.length ; i++ ) {
            _amount += UserDonation[_user][Assos[i].wallet];
        }
        for (uint256 i = 0 ; i < OldAssos.length ; i++ ) {
            _amount += UserDonation[_user][OldAssos[i].wallet];
        }
        return _amount;
    }
    function resetUserTest(address _user, address _asso) public onlyOwner {
        UserDonation[_user][_asso] = 0;
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
    modifier onlyVault() {
        require(msg.sender == vault, "Only vault can do that");
        _;
    }
}