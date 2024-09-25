// Author: Jacob Thomas Messer
// Phone: 6573469599

// Author: Jacob Thomas Messer


const CrossChainHotSwapper = artifacts.require("CrossChainHotSwapper");

contract("CrossChainHotSwapper", (accounts) => {
    let crossChainHotSwapper;
    const [owner, newContract, oracle, bridge, recipient] = accounts;

    beforeEach(async () => {
        crossChainHotSwapper = await CrossChainHotSwapper.new(oracle, bridge, { from: owner });
    });

    it("should request a cross-chain contract swap", async () => {
        const requestId = 1;
        const targetChainId = 100;
        const metadata = web3.utils.toHex("SwapMetaData");
        const tx = await crossChainHotSwapper.requestSwap(requestId, newContract, targetChainId, metadata, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "CrossChainSwapRequested");
        assert.equal(tx.logs[0].args.newContract, newContract);
        assert.equal(tx.logs[0].args.targetChainId, targetChainId);
    });

    it("should execute the cross-chain contract swap", async () => {
        const requestId = 1;
        const targetChainId = 100;
        const metadata = web3.utils.toHex("SwapMetaData");
        await crossChainHotSwapper.requestSwap(requestId, newContract, targetChainId, metadata, { from: owner });

        const tx = await crossChainHotSwapper.executeSwap(requestId, { from: owner });

        // Check if the event was emitted
        assert.equal(tx.logs[0].event, "CrossChainSwapExecuted");
        assert.equal(tx.logs[0].args.newContract, newContract);
    });

    it("should validate the cross-chain transfer proof", async () => {
        const proof = web3.utils.toHex("ValidProof");
        const data = web3.utils.toHex("CrossChainData");

        const isValid = await crossChainHotSwapper.validateCrossChainTransfer(data, proof, { from: oracle });
        assert.equal(isValid, true);
    });
});

contract("CrossChainHotSwapper - Advanced Tests", (accounts) => {
    let crossChainHotSwapper;
    const [owner, newContract, oracle, bridge, recipient, otherChainContract] = accounts;

    beforeEach(async () => {
        crossChainHotSwapper = await CrossChainHotSwapper.new(oracle, bridge, { from: owner });
    });

    it("should fail to request a swap from unauthorized user", async () => {
        const requestId = 2;
        const targetChainId = 200;
        const metadata = web3.utils.toHex("UnauthorizedSwap");

        try {
            await crossChainHotSwapper.requestSwap(requestId, newContract, targetChainId, metadata, { from: recipient });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert.include(error.message, "onlyOwnerOrOracle", "Expected onlyOwnerOrOracle error");
        }
    });

    it("should handle multi-chain swaps", async () => {
        const requestId = 3;
        const targetChainIds = [100, 200];
        const contracts = [newContract, otherChainContract];
        const metadata = [web3.utils.toHex("SwapMeta1"), web3.utils.toHex("SwapMeta2")];

        const tx = await crossChainHotSwapper.requestMultiChainSwap(requestId, contracts, targetChainIds, metadata, { from: owner });

        // Validate multi-chain swap request
        assert.equal(tx.logs[0].event, "MultiChainSwapRequested");
        assert.deepEqual(tx.logs[0].args.newContracts, contracts);
        assert.deepEqual(tx.logs[0].args.targetChainIds, targetChainIds);
    });

    it("should execute multi-chain swaps successfully", async () => {
        const requestId = 4;
        const targetChainIds = [100, 200];
        const contracts = [newContract, otherChainContract];
        const metadata = [web3.utils.toHex("SwapMeta1"), web3.utils.toHex("SwapMeta2")];

        await crossChainHotSwapper.requestMultiChainSwap(requestId, contracts, targetChainIds, metadata, { from: owner });
        const tx = await crossChainHotSwapper.executeMultiChainSwap(requestId, { from: owner });

        // Validate multi-chain swap execution
        assert.equal(tx.logs[0].event, "MultiChainSwapExecuted");
        assert.deepEqual(tx.logs[0].args.newContracts, contracts);
    });

    it("should register new blockchain for cross-chain swap", async () => {
        const chainId = 300;
        const chainName = "TestNetChain";
        const tx = await crossChainHotSwapper.registerChain(chainId, chainName, { from: owner });

        // Validate chain registration
        assert.equal(tx.logs[0].event, "ChainRegistered");
        assert.equal(tx.logs[0].args.chainId, chainId);
        assert.equal(tx.logs[0].args.chainName, chainName);
    });

    it("should handle invalid cross-chain transfer proof", async () => {
        const invalidProof = web3.utils.toHex("InvalidProof");
        const data = web3.utils.toHex("InvalidData");

        const isValid = await crossChainHotSwapper.validateCrossChainTransfer(data, invalidProof, { from: oracle });
        assert.equal(isValid, false);
    });
});
