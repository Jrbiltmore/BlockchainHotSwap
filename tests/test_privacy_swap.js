// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


const ZKPHotSwapper = artifacts.require("ZKPHotSwapper");

contract("ZKPHotSwapper", (accounts) => {
    let zkpHotSwapper;
    const [owner, verifier, user] = accounts;

    beforeEach(async () => {
        zkpHotSwapper = await ZKPHotSwapper.new(verifier, { from: owner });
    });

    it("should verify a ZKP proof before swap", async () => {
        const proof = web3.utils.toHex("ValidProof");
        const inputs = web3.utils.toHex("ZKPInputs");

        const isValid = await zkpHotSwapper.verifyProof(proof, inputs, { from: verifier });
        assert.equal(isValid, true);
    });

    it("should fail to verify an invalid ZKP proof", async () => {
        const invalidProof = web3.utils.toHex("InvalidProof");
        const inputs = web3.utils.toHex("ZKPInputs");

        const isValid = await zkpHotSwapper.verifyProof(invalidProof, inputs, { from: verifier });
        assert.equal(isValid, false);
    });

    it("should execute a privacy-preserving token swap", async () => {
        const requestId = 1;
        const proof = web3.utils.toHex("ValidProof");
        const metadata = web3.utils.toHex("PrivacySwapMeta");

        await zkpHotSwapper.requestSwap(requestId, proof, metadata, { from: owner });
        const tx = await zkpHotSwapper.executeSwap(requestId, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "SwapExecuted");
        assert.equal(tx.logs[0].args.requestId, requestId);
    });
});

contract("ZKPHotSwapper - Advanced Tests", (accounts) => {
    let zkpHotSwapper;
    const [owner, verifier, user, newContract] = accounts;

    beforeEach(async () => {
        zkpHotSwapper = await ZKPHotSwapper.new(verifier, { from: owner });
    });

    it("should reject a swap request with invalid ZKP proof", async () => {
        const requestId = 2;
        const invalidProof = web3.utils.toHex("InvalidProof");
        const metadata = web3.utils.toHex("InvalidPrivacySwap");

        try {
            await zkpHotSwapper.requestSwap(requestId, invalidProof, metadata, { from: user });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "Invalid ZKP proof", "Expected invalid ZKP proof error");
        }
    });

    it("should allow multiple privacy swaps in batch mode", async () => {
        const requestId = 3;
        const proofs = [web3.utils.toHex("ValidProof1"), web3.utils.toHex("ValidProof2")];
        const metadata = [web3.utils.toHex("PrivacySwapMeta1"), web3.utils.toHex("PrivacySwapMeta2")];

        const tx = await zkpHotSwapper.requestBatchSwap(requestId, proofs, metadata, { from: owner });

        // Validate batch swap request
        assert.equal(tx.logs[0].event, "BatchSwapRequested");
        assert.deepEqual(tx.logs[0].args.proofs, proofs);
        assert.deepEqual(tx.logs[0].args.metadata, metadata);
    });

    it("should execute batch privacy swaps successfully", async () => {
        const requestId = 4;
        const proofs = [web3.utils.toHex("ValidProof1"), web3.utils.toHex("ValidProof2")];
        const metadata = [web3.utils.toHex("PrivacySwapMeta1"), web3.utils.toHex("PrivacySwapMeta2")];

        await zkpHotSwapper.requestBatchSwap(requestId, proofs, metadata, { from: owner });
        const tx = await zkpHotSwapper.executeBatchSwap(requestId, { from: owner });

        // Validate batch swap execution
        assert.equal(tx.logs[0].event, "BatchSwapExecuted");
    });

    it("should rollback a privacy swap if verification fails", async () => {
        const requestId = 5;
        const invalidProof = web3.utils.toHex("InvalidProof");

        await zkpHotSwapper.requestSwap(requestId, invalidProof, "0x", { from: owner });
        try {
            await zkpHotSwapper.executeSwap(requestId, { from: owner });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "Invalid ZKP proof", "Expected invalid ZKP proof error");
        }

        const tx = await zkpHotSwapper.rollbackSwap(requestId, { from: owner });

        // Validate rollback execution
        assert.equal(tx.logs[0].event, "RollbackPerformed");
    });

    it("should verify state consistency in privacy swaps", async () => {
        const stateData = web3.utils.toHex("StateData");
        const expectedState = web3.utils.toHex("ExpectedState");

        const isValid = await zkpHotSwapper.verifyStateConsistency(stateData, expectedState, { from: verifier });
        assert.equal(isValid, true);
    });
});
