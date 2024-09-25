// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SharedStorage.sol";
import "./StateMigration.sol";
import "../governance/DAOHotSwapper.sol";
import "../cross-chain/CrossChainHotSwapper.sol";
import "../security/AccessControl.sol";
import "../security/MultiSigWallet.sol";
import "../quantum-safe/QuantumSafeHotSwapper.sol";

contract CoreContract is AccessControl, MultiSigWallet {
    SharedStorage public storageContract;
    StateMigration public stateMigration;
    DAOHotSwapper public daoSwapper;
    CrossChainHotSwapper public crossChainSwapper;
    QuantumSafeHotSwapper public quantumSafeSwapper;

    event ContractSwapped(address indexed oldContract, address indexed newContract);
    event StateMigrated(address indexed oldState, address indexed newState);
    event RoleAssigned(address indexed account, bytes32 role);
    event QuantumSecurityEnabled(bool enabled);
    
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not an admin");
        _;
    }

    constructor(
        address _storageContract,
        address _stateMigration,
        address _daoSwapper,
        address _crossChainSwapper,
        address _quantumSafeSwapper
    ) {
        storageContract = SharedStorage(_storageContract);
        stateMigration = StateMigration(_stateMigration);
        daoSwapper = DAOHotSwapper(_daoSwapper);
        crossChainSwapper = CrossChainHotSwapper(_crossChainSwapper);
        quantumSafeSwapper = QuantumSafeHotSwapper(_quantumSafeSwapper);

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function swapContract(address newContract) external onlyAdmin {
        address oldContract = address(this);
        storageContract.setActiveContract(newContract);
        emit ContractSwapped(oldContract, newContract);
    }

    function migrateState(bytes memory newState) external onlyAdmin {
        bytes memory oldState = stateMigration.saveState();
        stateMigration.restoreState(newState);
        emit StateMigrated(keccak256(oldState), keccak256(newState));
    }

    function assignRole(address account, bytes32 role) external onlyAdmin {
        grantRole(role, account);
        emit RoleAssigned(account, role);
    }

    function enableQuantumSecurity(bool enable) external onlyAdmin {
        quantumSafeSwapper.toggleQuantumSecurity(enable);
        emit QuantumSecurityEnabled(enable);
    }

    fallback() external payable {
        (bool success, ) = storageContract.activeContract().delegatecall(msg.data);
        require(success, "Delegate call failed.");
    }

    receive() external payable {}
}
