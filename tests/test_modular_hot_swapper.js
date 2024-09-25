// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


const ModularHotSwapper = artifacts.require("ModularHotSwapper");

contract("ModularHotSwapper", (accounts) => {
    let modularHotSwapper;
    const [owner, newConsensusModule, newExecutionModule, newDataModule] = accounts;

    beforeEach(async () => {
        modularHotSwapper = await ModularHotSwapper.new({ from: owner });
    });

    it("should swap the consensus module", async () => {
        const tx = await modularHotSwapper.swapConsensusModule(newConsensusModule, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "ModuleSwapped");
        assert.equal(tx.logs[0].args.moduleName, "Consensus");
        assert.equal(tx.logs[0].args.newModule, newConsensusModule);
    });

    it("should swap the execution module", async () => {
        const tx = await modularHotSwapper.swapExecutionModule(newExecutionModule, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "ModuleSwapped");
        assert.equal(tx.logs[0].args.moduleName, "Execution");
        assert.equal(tx.logs[0].args.newModule, newExecutionModule);
    });

    it("should swap the data availability module", async () => {
        const tx = await modularHotSwapper.swapDataAvailabilityModule(newDataModule, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "ModuleSwapped");
        assert.equal(tx.logs[0].args.moduleName, "Data Availability");
        assert.equal(tx.logs[0].args.newModule, newDataModule);
    });
});

contract("ModularHotSwapper - Advanced Tests", (accounts) => {
    let modularHotSwapper;
    const [owner, newConsensusModule, newExecutionModule, newDataModule, user] = accounts;

    beforeEach(async () => {
        modularHotSwapper = await ModularHotSwapper.new({ from: owner });
    });

    it("should fail to swap the consensus module from unauthorized user", async () => {
        try {
            await modularHotSwapper.swapConsensusModule(newConsensusModule, { from: user });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "onlyOwner", "Expected onlyOwner error");
        }
    });

    it("should handle multi-module swaps", async () => {
        const modules = {
            consensus: newConsensusModule,
            execution: newExecutionModule,
            data: newDataModule
        };

        const tx = await modularHotSwapper.swapMultipleModules(modules, { from: owner });

        // Validate multi-module swap request
        assert.equal(tx.logs[0].event, "MultiModuleSwapped");
        assert.equal(tx.logs[0].args.consensusModule, newConsensusModule);
        assert.equal(tx.logs[0].args.executionModule, newExecutionModule);
        assert.equal(tx.logs[0].args.dataModule, newDataModule);
    });

    it("should prevent swapping modules with invalid addresses", async () => {
        try {
            await modularHotSwapper.swapConsensusModule("0x0000000000000000000000000000000000000000", { from: owner });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "Invalid address", "Expected invalid address error");
        }
    });

    it("should revert to the previous module on failure", async () => {
        const previousModule = await modularHotSwapper.consensusModule();
        const invalidModule = "0x0000000000000000000000000000000000000000";

        try {
            await modularHotSwapper.swapConsensusModule(invalidModule, { from: owner });
        } catch (error) {
            // Ensure the module didn't change
            const currentModule = await modularHotSwapper.consensusModule();
            assert.equal(currentModule, previousModule);
        }
    });

    it("should verify the integrity of state migration across modules", async () => {
        const stateData = web3.utils.toHex("StateDataExample");
        const tx = await modularHotSwapper.migrateStateAcrossModules(stateData, { from: owner });

        // Validate state migration
        assert.equal(tx.logs[0].event, "StateMigrationPerformed");
        assert.equal(tx.logs[0].args.stateData, stateData);
    });
});
