import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const YAMORegistry = await ethers.getContractFactory("YAMORegistry");
  
  // Use the deployer address as the default admin
  const registry = await upgrades.deployProxy(YAMORegistry, [deployer.address], {
    initializer: "initialize",
    kind: "uups",
  });

  await registry.waitForDeployment();

  console.log("YAMORegistry deployed to:", await registry.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
