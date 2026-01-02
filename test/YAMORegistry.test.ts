import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

describe("YAMORegistry (UUPS Upgrade)", function () {
  let registry: any;
  let owner: any;
  let agent: any;

  beforeEach(async function () {
    [owner, agent] = await ethers.getSigners();
    
    // Deploy V1
    const YAMORegistry = await ethers.getContractFactory("YAMORegistry");
    registry = await upgrades.deployProxy(YAMORegistry, [owner.address], {
      initializer: "initialize",
      kind: "uups",
    });
    await registry.waitForDeployment();
  });

  it("should support V1 basic anchoring", async function () {
    const blockId = "001";
    const contentHash = ethers.id("test-content");
    
    await registry.submitBlock(blockId, "0", contentHash, "manual", "test");
    
    const block = await registry.blocks(blockId);
    expect(block.contentHash).to.equal(contentHash);
  });

  it("should upgrade to V2 and preserve state", async function () {
    // 1. Submit V1 Block
    await registry.submitBlock("001", "0", ethers.id("v1-content"), "manual", "test");

    // 2. Upgrade to V2
    const YAMORegistryV2 = await ethers.getContractFactory("YAMORegistryV2");
    const registryV2 = await upgrades.upgradeProxy(await registry.getAddress(), YAMORegistryV2);
    
    // 3. Verify V1 State
    const blockV1 = await registryV2.blocks("001");
    expect(blockV1.contentHash).to.equal(ethers.id("v1-content"));

    // 4. Submit V2 Block (with IPFS)
    await registryV2.submitBlockV2(
        "002", 
        "001", 
        ethers.id("v2-content"), 
        "manual", 
        "test", 
        "QmTestCID"
    );

    // 5. Verify V2 State
    const cid = await registryV2.blockCIDs("002");
    expect(cid).to.equal("QmTestCID");
  });
});
