// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


const DAOHotSwapper = artifacts.require("DAOHotSwapper");

contract("DAOHotSwapper", (accounts) => {
    let daoHotSwapper;
    const [owner, newContract, voter1, voter2] = accounts;

    beforeEach(async () => {
        daoHotSwapper = await DAOHotSwapper.new({ from: owner });
    });

    it("should create a new proposal for contract swap", async () => {
        const proposalId = 1;
        const tx = await daoHotSwapper.createProposal(newContract, { from: voter1 });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "ProposalCreated");
        assert.equal(tx.logs[0].args.proposer, voter1);
        assert.equal(tx.logs[0].args.newContract, newContract);
    });

    it("should allow voting on a contract swap proposal", async () => {
        const proposalId = 1;
        await daoHotSwapper.createProposal(newContract, { from: voter1 });
        const tx = await daoHotSwapper.voteOnProposal(proposalId, true, { from: voter2 });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "VoteCast");
        assert.equal(tx.logs[0].args.voter, voter2);
        assert.equal(tx.logs[0].args.approved, true);
    });

    it("should execute the swap after successful voting", async () => {
        const proposalId = 1;
        await daoHotSwapper.createProposal(newContract, { from: voter1 });
        await daoHotSwapper.voteOnProposal(proposalId, true, { from: voter2 });

        const tx = await daoHotSwapper.executeProposal(proposalId, { from: owner });

        // Check if the swap was executed
        assert.equal(tx.logs[0].event, "ProposalExecuted");
        assert.equal(tx.logs[0].args.newContract, newContract);
    });
});

contract("DAOHotSwapper - Advanced Tests", (accounts) => {
    let daoHotSwapper;
    const [owner, newContract, voter1, voter2, voter3] = accounts;

    beforeEach(async () => {
        daoHotSwapper = await DAOHotSwapper.new({ from: owner });
    });

    it("should fail to create a proposal with invalid contract address", async () => {
        try {
            await daoHotSwapper.createProposal("0x0000000000000000000000000000000000000000", { from: voter1 });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "Invalid contract address", "Expected invalid contract address error");
        }
    });

    it("should allow multiple voters to vote on the same proposal", async () => {
        const proposalId = 2;
        await daoHotSwapper.createProposal(newContract, { from: voter1 });
        await daoHotSwapper.voteOnProposal(proposalId, true, { from: voter2 });
        const tx = await daoHotSwapper.voteOnProposal(proposalId, false, { from: voter3 });

        // Validate that both votes were counted
        assert.equal(tx.logs[0].event, "VoteCast");
        assert.equal(tx.logs[0].args.voter, voter3);
        assert.equal(tx.logs[0].args.approved, false);
    });

    it("should prevent duplicate voting from the same voter", async () => {
        const proposalId = 3;
        await daoHotSwapper.createProposal(newContract, { from: voter1 });
        await daoHotSwapper.voteOnProposal(proposalId, true, { from: voter2 });

        try {
            await daoHotSwapper.voteOnProposal(proposalId, false, { from: voter2 });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "Already voted", "Expected already voted error");
        }
    });

    it("should correctly execute a proposal with majority approval", async () => {
        const proposalId = 4;
        await daoHotSwapper.createProposal(newContract, { from: voter1 });
        await daoHotSwapper.voteOnProposal(proposalId, true, { from: voter2 });
        await daoHotSwapper.voteOnProposal(proposalId, true, { from: voter3 });

        const tx = await daoHotSwapper.executeProposal(proposalId, { from: owner });

        // Check if the proposal was executed and swap occurred
        assert.equal(tx.logs[0].event, "ProposalExecuted");
        assert.equal(tx.logs[0].args.newContract, newContract);
    });

    it("should reject proposal execution if not enough votes are cast", async () => {
        const proposalId = 5;
        await daoHotSwapper.createProposal(newContract, { from: voter1 });
        await daoHotSwapper.voteOnProposal(proposalId, true, { from: voter2 });

        try {
            await daoHotSwapper.executeProposal(proposalId, { from: owner });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "Not enough votes", "Expected not enough votes error");
        }
    });
});
