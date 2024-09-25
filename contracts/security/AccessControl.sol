// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Access control contract to manage roles and permissions for governance and security purposes
// Implements role-based access control to ensure that only authorized entities can perform certain actions

contract AccessControl {

    // Mapping to store the roles and permissions
    mapping(address => bool) public admins;

    // Event emitted when a new admin is added
    event AdminAdded(address indexed newAdmin);

    // Event emitted when an admin is removed
    event AdminRemoved(address indexed admin);

    // Modifier to restrict functions to only be called by admins
    modifier onlyAdmin() {
        require(admins[msg.sender], "Caller is not an admin");
        _;
    }

    // Constructor to initialize the deployer as the first admin
    constructor() {
        admins[msg.sender] = true;
        emit AdminAdded(msg.sender);
    }

    // Function to add a new admin
    function addAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admins[newAdmin] = true;
        emit AdminAdded(newAdmin);
    }

    // Function to remove an admin
    function removeAdmin(address admin) public onlyAdmin {
        require(admin != msg.sender, "Cannot remove self");
        admins[admin] = false;
        emit AdminRemoved(admin);
    }

    // Example of a critical function restricted to admins
    function performAdminAction() public onlyAdmin {
        // Critical logic for admins goes here
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// Advanced Access Control contract using role-based permissions and governance mechanisms
// Ensures that different roles have appropriate permissions for critical operations

contract AccessControl is AccessControlEnumerable {

    // Define roles using bytes32 identifiers
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    // Event emitted when a new operator is added
    event OperatorAdded(address indexed newOperator);

    // Event emitted when an operator is removed
    event OperatorRemoved(address indexed operator);

    // Constructor to initialize the deployer as the first admin
    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    // Modifier to restrict functions to only be called by admins
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    // Modifier to restrict functions to only be called by operators
    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, msg.sender), "Caller is not an operator");
        _;
    }

    // Function to grant the operator role to an account
    function addOperator(address newOperator) public onlyAdmin {
        grantRole(OPERATOR_ROLE, newOperator);
        emit OperatorAdded(newOperator);
    }

    // Function to revoke the operator role from an account
    function removeOperator(address operator) public onlyAdmin {
        revokeRole(OPERATOR_ROLE, operator);
        emit OperatorRemoved(operator);
    }

    // Function to perform a critical admin action, restricted to admins
    function performAdminAction() public onlyAdmin {
        // Critical logic for admin role
    }

    // Function to perform an operator action, restricted to operators
    function performOperatorAction() public onlyOperator {
        // Critical logic for operator role
    }

    // Function to check if an account has the admin role
    function isAdmin(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    // Function to check if an account has the operator role
    function isOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }
}
