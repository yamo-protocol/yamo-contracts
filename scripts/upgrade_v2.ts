import { ethers, upgrades } from "hardhat";

async function main() {
  const proxyAddress = process.env.PROXY_ADDRESS; // We will pass this in
  if (!proxyAddress) {
    console.error("Error: PROXY_ADDRESS environment variable is required.");
    process.exit(1);
  }

  console.log("Upgrading YAMORegistry at:", proxyAddress);

  const YAMORegistryV2 = await ethers.getContractFactory("YAMORegistryV2");
  
  // Validate and deploy implementation, then upgrade proxy
  const upgraded = await upgrades.upgradeProxy(proxyAddress, YAMORegistryV2);
  
  await upgraded.waitForDeployment();

  console.log("YAMORegistry upgraded to V2 successfully.");
  console.log("Implementation address:", await upgrades.erc1967.getImplementationAddress(proxyAddress));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
