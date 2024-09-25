// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Pausable contract to allow pausing and unpausing of certain functions during upgrades or emergency situations
// Implements role-based control for governance to pause and unpause critical operations

contract PausableContract {

    // State variable to track whether the contract is paused
    bool public paused;

    // Event emitted when the contract is paused
    event Paused(address indexed pauser);

    // Event emitted when the contract is unpaused
    event Unpaused(address indexed pauser);

    // Modifier to restrict functions to only run when not paused
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    // Modifier to restrict functions to only run when paused
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    // Constructor to initialize the contract in an unpaused state
    constructor() {
        paused = false;
    }

    // Function to pause the contract
    function pause() public whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    // Function to unpause the contract
    function unpause() public whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    // Example function that can only be called when the contract is not paused
    function performCriticalAction() public whenNotPaused {
        // Critical action logic goes here
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// Advanced Pausable contract to enable emergency pause/unpause functionality for critical systems
// Provides secure control over operations that may need to be suspended during contract upgrades or unforeseen events

contract PausableContract is Ownable {

    // State variable to track the paused status of the contract
    bool public paused;

    // Event emitted when the contract is paused
    event Paused(address indexed pauser);

    // Event emitted when the contract is unpaused
    event Unpaused(address indexed pauser);

    // Modifier to restrict functions to run only when the contract is not paused
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    // Modifier to restrict functions to run only when the contract is paused
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    // Constructor to initialize the contract in an unpaused state
    constructor() {
        paused = false;
    }

    // Function to pause the contract, restricted to the contract owner
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    // Function to unpause the contract, restricted to the contract owner
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    // Critical function that can only be called when the contract is not paused
    function performCriticalAction() public whenNotPaused {
        // Logic for critical action
    }

    // Emergency function that can only be called when the contract is paused
    function performEmergencyAction() public whenPaused {
        // Logic for emergency action during pause
    }

    // Function to check if the contract is currently paused
    function isPaused() public view returns (bool) {
        return paused;
    }
}
