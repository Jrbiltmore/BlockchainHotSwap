// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for Oracle contracts used in cross-chain, AI, or prediction-based swaps
// Oracles provide external data or predictions that influence swap decisions

interface IOracle {

    // Function to retrieve the latest data from the oracle
    function getLatestData() external view returns (bytes memory);

    // Function to verify the validity of oracle data
    function verifyData(bytes memory data) external view returns (bool);

    // Event emitted when new data is retrieved from the oracle
    event DataRetrieved(bytes data);

    // Event emitted when oracle data is verified
    event DataVerified(bool validity);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Advanced Oracle Interface for Blockchain Hot Swapper system
// Defines additional functions for predictive models, cross-chain operations, and AI-driven decision-making

interface IOracle {

    // Function to retrieve the latest data from the oracle, including prediction-based or cross-chain data
    function getLatestData() external view returns (bytes memory);

    // Function to retrieve a prediction result from the oracle
    function getPrediction(bytes calldata inputData) external view returns (bool prediction);

    // Function to verify and validate oracle data, particularly for cross-chain and swap decisions
    function verifyData(bytes memory data) external view returns (bool);

    // Function to fetch cross-chain data or any external blockchain information
    function getCrossChainData(uint256 chainId) external view returns (bytes memory);

    // Event emitted when new data is retrieved from the oracle
    event DataRetrieved(bytes data);

    // Event emitted when a prediction is returned by the oracle
    event PredictionMade(bool prediction);

    // Event emitted when oracle data is verified successfully
    event DataVerified(bool validity);

    // Event emitted when cross-chain data is retrieved successfully
    event CrossChainDataRetrieved(uint256 chainId, bytes data);
}
