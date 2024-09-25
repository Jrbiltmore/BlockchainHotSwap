// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Multi-signature wallet-based governance for BlockchainHotSwapper
// Allows multiple stakeholders to approve contract swaps

contract MultiSigHotSwapper {

    // Struct representing a multi-sig approval for a contract swap
    struct SwapApproval {
        address approver;
        uint256 approvalTimestamp;
        bool approved;
    }

    // Array to track all signers (addresses)
    address[] public signers;

    // Mapping from proposal IDs to the approvals for each swap
    mapping(uint256 => mapping(address => SwapApproval)) public approvals;

    // Minimum number of signers required to approve a swap
    uint256 public requiredSigners;

    // Event emitted when a new proposal is created
    event SwapProposalCreated(uint256 indexed proposalId, address proposer);

    // Event emitted when a proposal is approved
    event SwapApproved(uint256 indexed proposalId, address approver);

    // Event emitted when a proposal is executed
    event SwapExecuted(uint256 indexed proposalId, address newContract);

    // Constructor to initialize the list of signers and required number of approvals
    constructor(address[] memory initialSigners, uint256 minSigners) {
        require(minSigners <= initialSigners.length, "Signers required exceeds available signers");
        signers = initialSigners;
        requiredSigners = minSigners;
    }

    // Modifier to ensure only authorized signers can call certain functions
    modifier onlySigner() {
        require(isSigner(msg.sender), "Not an authorized signer");
        _;
    }

    // Function to propose a new contract swap
    function proposeSwap(uint256 proposalId, address newContract) public onlySigner {
        require(newContract != address(0), "Invalid new contract address");

        // Emit an event for the swap proposal
        emit SwapProposalCreated(proposalId, msg.sender);
    }

    // Function to approve a contract swap proposal
    function approveSwap(uint256 proposalId) public onlySigner {
        approvals[proposalId][msg.sender] = SwapApproval({
            approver: msg.sender,
            approvalTimestamp: block.timestamp,
            approved: true
        });

        // Emit an event for the approval
        emit SwapApproved(proposalId, msg.sender);

        // Check if the swap can be executed
        if (getApprovalCount(proposalId) >= requiredSigners) {
            executeSwap(proposalId);
        }
    }

    // Function to execute a contract swap if enough approvals are collected
    function executeSwap(uint256 proposalId) internal {
        address newContract = getNewContractForProposal(proposalId);
        require(newContract != address(0), "Invalid new contract");

        // Emit an event for the swap execution
        emit SwapExecuted(proposalId, newContract);

        // Call the hot swapper to execute the contract swap
        BlockchainHotSwapper(newContract).loadNewContract(newContract);
    }

    // Helper function to count the number of approvals for a proposal
    function getApprovalCount(uint256 proposalId) public view returns (uint256 count) {
        for (uint256 i = 0; i < signers.length; i++) {
            if (approvals[proposalId][signers[i]].approved) {
                count++;
            }
        }
    }

    // Helper function to check if an address is a signer
    function isSigner(address account) public view returns (bool) {
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == account) {
                return true;
            }
        }
        return false;
    }

    // Placeholder function to retrieve the new contract for a given proposal ID
    function getNewContractForProposal(uint256 proposalId) internal view returns (address) {
        // Placeholder logic to retrieve the contract (can be improved)
        return address(0); // Replace with actual logic
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../core/BlockchainHotSwapper.sol";

// Advanced multi-signature wallet-based governance for secure, multi-party approval of contract swaps
// Allows for sophisticated voting mechanisms, event logging, and security enforcement

contract MultiSigHotSwapper {

    // Struct representing an approval for a contract swap
    struct SwapApproval {
        address approver;
        uint256 approvalTimestamp;
        bool approved;
    }

    // List of authorized signers
    address[] public signers;

    // Minimum number of signers required to approve a contract swap
    uint256 public requiredSigners;

    // Mapping of proposal IDs to approvals
    mapping(uint256 => mapping(address => SwapApproval)) public approvals;

    // Proposal to new contract mapping
    mapping(uint256 => address) public swapProposals;

    // Event emitted when a swap proposal is created
    event SwapProposalCreated(uint256 indexed proposalId, address proposer, address newContract);

    // Event emitted when a signer approves a swap proposal
    event SwapApproved(uint256 indexed proposalId, address approver);

    // Event emitted when a swap is executed
    event SwapExecuted(uint256 indexed proposalId, address newContract);

    // Constructor to initialize the list of signers and required number of approvals
    constructor(address[] memory initialSigners, uint256 minSigners) {
        require(minSigners <= initialSigners.length, "Required signers exceed available signers");
        signers = initialSigners;
        requiredSigners = minSigners;
    }

    // Modifier to ensure only authorized signers can call certain functions
    modifier onlySigner() {
        require(isSigner(msg.sender), "Not an authorized signer");
        _;
    }

    // Function to propose a new contract swap
    function proposeSwap(uint256 proposalId, address newContract) public onlySigner {
        require(newContract != address(0), "Invalid contract address");

        swapProposals[proposalId] = newContract;

        emit SwapProposalCreated(proposalId, msg.sender, newContract);
    }

    // Function to approve a contract swap proposal
    function approveSwap(uint256 proposalId) public onlySigner {
        approvals[proposalId][msg.sender] = SwapApproval({
            approver: msg.sender,
            approvalTimestamp: block.timestamp,
            approved: true
        });

        emit SwapApproved(proposalId, msg.sender);

        // Execute the swap if enough approvals are collected
        if (getApprovalCount(proposalId) >= requiredSigners) {
            executeSwap(proposalId);
        }
    }

    // Internal function to execute the contract swap once approved
    function executeSwap(uint256 proposalId) internal {
        address newContract = swapProposals[proposalId];
        require(newContract != address(0), "Invalid contract address");

        BlockchainHotSwapper(newContract).loadNewContract(newContract);

        emit SwapExecuted(proposalId, newContract);
    }

    // Helper function to count the number of approvals for a given proposal
    function getApprovalCount(uint256 proposalId) public view returns (uint256 count) {
        for (uint256 i = 0; i < signers.length; i++) {
            if (approvals[proposalId][signers[i]].approved) {
                count++;
            }
        }
    }

    // Helper function to verify if an address is one of the authorized signers
    function isSigner(address account) public view returns (bool) {
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == account) {
                return true;
            }
        }
        return false;
    }

    // Function to remove an existing signer (only signers can call this)
    function removeSigner(address signer) public onlySigner {
        require(isSigner(signer), "Address is not a signer");
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == signer) {
                signers[i] = signers[signers.length - 1]; // Replace with the last signer
                signers.pop();
                break;
            }
        }
    }

    // Function to add a new signer to the multi-sig wallet
    function addSigner(address newSigner) public onlySigner {
        require(!isSigner(newSigner), "Address is already a signer");
        signers.push(newSigner);
    }
}
