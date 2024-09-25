// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for Bridge contracts used for cross-chain swaps and asset transfers
// Bridges facilitate the movement of assets and contract states between different blockchain networks

interface IBridge {

    // Function to transfer an asset to another blockchain
    function transferToChain(address recipient, uint256 amount, uint256 targetChainId) external;

    // Function to receive an asset from another blockchain
    function receiveFromChain(address sender, uint256 amount, uint256 sourceChainId) external;

    // Event emitted when an asset is transferred to another chain
    event AssetTransferredToChain(address indexed recipient, uint256 amount, uint256 targetChainId);

    // Event emitted when an asset is received from another chain
    event AssetReceivedFromChain(address indexed sender, uint256 amount, uint256 sourceChainId);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Advanced Bridge Interface for Blockchain Hot Swapper system
// Designed for secure and reliable cross-chain swaps, allowing contract, asset, and state transfers between blockchains

interface IBridge {

    // Function to transfer assets or contract states to another blockchain, with additional metadata for validation
    function transferToChain(address recipient, uint256 amount, uint256 targetChainId, bytes calldata metadata) external;

    // Function to receive assets or contract states from another blockchain, validating the metadata and proof
    function receiveFromChain(address sender, uint256 amount, uint256 sourceChainId, bytes calldata proof, bytes calldata metadata) external;

    // Function to validate cross-chain transfers, ensuring that the transferred data and assets are consistent
    function validateCrossChainTransfer(bytes calldata data, bytes calldata proof) external view returns (bool);

    // Function to register new supported blockchain networks for cross-chain transfers
    function registerChain(uint256 chainId, string calldata chainName) external;

    // Event emitted when an asset or contract state is transferred to another chain
    event AssetTransferredToChain(address indexed recipient, uint256 amount, uint256 targetChainId, bytes metadata);

    // Event emitted when an asset or contract state is received from another chain
    event AssetReceivedFromChain(address indexed sender, uint256 amount, uint256 sourceChainId, bytes proof, bytes metadata);

    // Event emitted when a new blockchain network is registered for cross-chain swaps
    event ChainRegistered(uint256 chainId, string chainName);
}
