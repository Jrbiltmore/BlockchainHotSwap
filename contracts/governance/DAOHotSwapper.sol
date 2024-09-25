// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// DAO-based governance for the BlockchainHotSwapper
// This contract allows token holders to vote on contract swaps

contract DAOHotSwapper {

    // Struct representing a proposal for a contract swap
    struct SwapProposal {
        address proposer;
        address newContract;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 deadline;
        bool executed;
    }

    // Mapping of proposal IDs to proposals
    mapping(uint256 => SwapProposal) public proposals;

    // Governance token balances (used for voting power)
    mapping(address => uint256) public governanceTokenBalances;

    // Minimum number of votes required to pass a proposal
    uint256 public voteThreshold;

    // Event emitted when a new proposal is created
    event ProposalCreated(uint256 indexed proposalId, address proposer, address newContract);

    // Event emitted when a proposal is executed
    event ProposalExecuted(uint256 indexed proposalId, address newContract);

    // Function to create a new proposal for a contract swap
    function createProposal(address newContract) public {
        require(governanceTokenBalances[msg.sender] > 0, "Must hold governance tokens to propose");

        uint256 proposalId = block.number; // Use block number as a unique ID
        proposals[proposalId] = SwapProposal({
            proposer: msg.sender,
            newContract: newContract,
            yesVotes: 0,
            noVotes: 0,
            deadline: block.timestamp + 1 weeks,
            executed: false
        });

        emit ProposalCreated(proposalId, msg.sender, newContract);
    }

    // Function to vote on a proposal
    function voteOnProposal(uint256 proposalId, bool approve) public {
        require(governanceTokenBalances[msg.sender] > 0, "Must hold governance tokens to vote");
        SwapProposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!proposal.executed, "Proposal already executed");

        if (approve) {
            proposal.yesVotes += governanceTokenBalances[msg.sender];
        } else {
            proposal.noVotes += governanceTokenBalances[msg.sender];
        }
    }

    // Function to execute a proposal if it passes
    function executeProposal(uint256 proposalId) public {
        SwapProposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period is still active");
        require(proposal.yesVotes > proposal.noVotes, "Proposal did not pass");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        BlockchainHotSwapper(proposal.newContract).loadNewContract(proposal.newContract);

        emit ProposalExecuted(proposalId, proposal.newContract);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../core/BlockchainHotSwapper.sol";

// Advanced DAO-based governance system for managing hot swaps in a decentralized manner
// Supports dynamic token-weighted voting, proposal tracking, and advanced governance features

contract DAOHotSwapper {

    // Struct for a contract swap proposal
    struct SwapProposal {
        address proposer;
        address newContract;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 deadline;
        bool executed;
    }

    // List of all proposals with proposal ID as key
    mapping(uint256 => SwapProposal) public proposals;

    // Governance token balances for each address (used for voting weight)
    mapping(address => uint256) public governanceTokenBalances;

    // Tracking of voters and proposals they voted on
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Minimum number of yes votes required to execute a proposal
    uint256 public voteThreshold;

    // Event emitted when a proposal is created
    event ProposalCreated(uint256 indexed proposalId, address proposer, address newContract);

    // Event emitted when a vote is cast on a proposal
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool approve, uint256 votes);

    // Event emitted when a proposal is executed
    event ProposalExecuted(uint256 indexed proposalId, address newContract);

    // Constructor to initialize governance token balances and vote threshold
    constructor(address[] memory initialGovernanceAddresses, uint256 minVotes) {
        for (uint i = 0; i < initialGovernanceAddresses.length; i++) {
            governanceTokenBalances[initialGovernanceAddresses[i]] = 1000; // For example purposes
        }
        voteThreshold = minVotes;
    }

    // Function to create a new proposal for a contract swap
    function createProposal(address newContract) public {
        require(governanceTokenBalances[msg.sender] > 0, "Must hold governance tokens to propose");

        uint256 proposalId = block.number; // Use block number as unique ID
        proposals[proposalId] = SwapProposal({
            proposer: msg.sender,
            newContract: newContract,
            yesVotes: 0,
            noVotes: 0,
            deadline: block.timestamp + 1 weeks,
            executed: false
        });

        emit ProposalCreated(proposalId, msg.sender, newContract);
    }

    // Function to vote on a contract swap proposal
    function voteOnProposal(uint256 proposalId, bool approve) public {
        require(governanceTokenBalances[msg.sender] > 0, "Must hold governance tokens to vote");
        require(!hasVoted[proposalId][msg.sender], "Already voted on this proposal");
        
        SwapProposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period has ended");

        if (approve) {
            proposal.yesVotes += governanceTokenBalances[msg.sender];
        } else {
            proposal.noVotes += governanceTokenBalances[msg.sender];
        }

        hasVoted[proposalId][msg.sender] = true;

        emit VoteCast(msg.sender, proposalId, approve, governanceTokenBalances[msg.sender]);
    }

    // Function to execute the contract swap if a proposal passes
    function executeProposal(uint256 proposalId) public {
        SwapProposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period is still active");
        require(proposal.yesVotes >= voteThreshold, "Not enough votes in favor");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        BlockchainHotSwapper(proposal.newContract).loadNewContract(proposal.newContract);

        emit ProposalExecuted(proposalId, proposal.newContract);
    }

    // Function to update governance token balances (can be used to adjust voting power)
    function updateGovernanceTokenBalance(address voter, uint256 newBalance) public onlyGovernance {
        governanceTokenBalances[voter] = newBalance;
    }

    // Modifier to restrict access to governance functions
    modifier onlyGovernance() {
        require(governanceTokenBalances[msg.sender] > 0, "Only governance addresses can execute");
        _;
    }
}
