// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


const BlockchainHotSwapper = artifacts.require("BlockchainHotSwapper");

contract("BlockchainHotSwapper", (accounts) => {
    let hotSwapper;
    const [owner, newContract, user] = accounts;

    beforeEach(async () => {
        hotSwapper = await BlockchainHotSwapper.new({ from: owner });
    });

    it("should request a contract swap", async () => {
        const requestId = 1;
        const tx = await hotSwapper.requestSwap(requestId, newContract, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "SwapRequested");
        assert.equal(tx.logs[0].args.requester, owner);
        assert.equal(tx.logs[0].args.newContract, newContract);
    });

    it("should execute the contract swap", async () => {
        const requestId = 1;
        await hotSwapper.requestSwap(requestId, newContract, { from: owner });
        const tx = await hotSwapper.executeSwap(requestId, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "SwapExecuted");
        assert.equal(tx.logs[0].args.newContract, newContract);
    });

    it("should roll back a contract swap", async () => {
        const requestId = 1;
        await hotSwapper.requestSwap(requestId, newContract, { from: owner });
        await hotSwapper.executeSwap(requestId, { from: owner });
        const tx = await hotSwapper.rollbackSwap(requestId, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "RollbackPerformed");
    });
});

contract("BlockchainHotSwapper - Advanced Tests", (accounts) => {
    let hotSwapper;
    const [owner, newContract, user, governance] = accounts;

    beforeEach(async () => {
        hotSwapper = await BlockchainHotSwapper.new({ from: owner });
    });

    it("should fail to request a swap from non-governance", async () => {
        const requestId = 2;
        try {
            await hotSwapper.requestSwap(requestId, newContract, { from: user });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "onlyGovernance", "Expected onlyGovernance error");
        }
    });

    it("should handle multi-contract swaps", async () => {
        const requestId = 3;
        const contracts = [newContract, governance];
        const tx = await hotSwapper.requestMultiSwap(requestId, contracts, { from: owner });

        // Validate multi-swap request
        assert.equal(tx.logs[0].event, "MultiSwapRequested");
        assert.deepEqual(tx.logs[0].args.newContracts, contracts);
    });

    it("should execute multi-contract swaps successfully", async () => {
        const requestId = 3;
        const contracts = [newContract, governance];
        await hotSwapper.requestMultiSwap(requestId, contracts, { from: owner });
        const tx = await hotSwapper.executeMultiSwap(requestId, { from: owner });

        // Validate multi-swap execution
        assert.equal(tx.logs[0].event, "MultiSwapExecuted");
        assert.deepEqual(tx.logs[0].args.newContracts, contracts);
    });

    it("should handle state migration during swaps", async () => {
        const requestId = 4;
        const stateData = web3.utils.toHex("stateMigrationExample");
        const tx = await hotSwapper.migrateState(requestId, stateData, { from: owner });

        // Validate state migration
        assert.equal(tx.logs[0].event, "StateMigrated");
        assert.equal(tx.logs[0].args.stateData, stateData);
    });

    it("should revert swap if unauthorized execution", async () => {
        const requestId = 5;
        try {
            await hotSwapper.executeSwap(requestId, { from: user });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "onlyGovernance", "Expected onlyGovernance error");
        }
    });
});
