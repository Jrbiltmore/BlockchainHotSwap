// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the Blockchain Hot Swapper contract
// Defines the essential functions that the BlockchainHotSwapper contract must implement

interface IBlockchainHotSwapper {

    // Function to request a new swap
    function requestSwap(uint256 requestId, address newContract) external;

    // Function to execute the swap
    function executeSwap(uint256 requestId) external;

    // Function to rollback to the previous contract in case of failure
    function rollbackSwap(uint256 requestId) external;

    // Event emitted when a swap request is created
    event SwapRequested(uint256 requestId, address indexed requester, address newContract);

    // Event emitted when a swap is successfully executed
    event SwapExecuted(uint256 requestId, address indexed newContract);

    // Event emitted when a rollback is performed
    event RollbackPerformed(uint256 requestId, address indexed previousContract);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Extended Interface for the Blockchain Hot Swapper
// This interface defines additional features such as multi-contract swaps, state migration, and governance controls

interface IBlockchainHotSwapper {

    // Function to request a new swap for multiple contracts
    function requestMultiSwap(uint256 requestId, address[] calldata newContracts) external;

    // Function to execute the multi-contract swap
    function executeMultiSwap(uint256 requestId) external;

    // Function to migrate the state to a new contract
    function migrateState(uint256 requestId, bytes calldata stateData) external;

    // Function to rollback to the previous set of contracts in case of failure
    function rollbackMultiSwap(uint256 requestId) external;

    // Governance function to authorize swap execution
    function authorizeSwapExecution(uint256 requestId) external;

    // Event emitted when a multi-contract swap request is created
    event MultiSwapRequested(uint256 requestId, address indexed requester, address[] newContracts);

    // Event emitted when a multi-contract swap is successfully executed
    event MultiSwapExecuted(uint256 requestId, address[] indexed newContracts);

    // Event emitted when a rollback is performed for multiple contracts
    event MultiRollbackPerformed(uint256 requestId, address[] indexed previousContracts);

    // Event emitted when the state is successfully migrated to the new contract
    event StateMigrated(uint256 requestId, address indexed newContract, bytes stateData);
}
