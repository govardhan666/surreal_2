import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Starting IPulse Studio contract deployment...\n");

  const [deployer] = await ethers.getSigners();
  console.log("📝 Deploying contracts with account:", deployer.address);
  console.log("💰 Account balance:", (await deployer.getBalance()).toString(), "\n");

  // Deploy IPMarketplace
  console.log("📦 Deploying IPMarketplace...");
  const IPMarketplace = await ethers.getContractFactory("IPMarketplace");
  const marketplace = await IPMarketplace.deploy();
  await marketplace.waitForDeployment();
  const marketplaceAddress = await marketplace.getAddress();
  console.log("✅ IPMarketplace deployed to:", marketplaceAddress);

  // Deploy RoyaltyDistributor
  console.log("\n📦 Deploying RoyaltyDistributor...");
  const RoyaltyDistributor = await ethers.getContractFactory("RoyaltyDistributor");
  const royaltyDistributor = await RoyaltyDistributor.deploy();
  await royaltyDistributor.waitForDeployment();
  const royaltyDistributorAddress = await royaltyDistributor.getAddress();
  console.log("✅ RoyaltyDistributor deployed to:", royaltyDistributorAddress);

  // Deploy DerivativeTracker
  console.log("\n📦 Deploying DerivativeTracker...");
  const DerivativeTracker = await ethers.getContractFactory("DerivativeTracker");
  const derivativeTracker = await DerivativeTracker.deploy();
  await derivativeTracker.waitForDeployment();
  const derivativeTrackerAddress = await derivativeTracker.getAddress();
  console.log("✅ DerivativeTracker deployed to:", derivativeTrackerAddress);

  // Save deployment addresses
  const network = await ethers.provider.getNetwork();
  const deploymentInfo = {
    network: {
      name: network.name,
      chainId: Number(network.chainId),
    },
    deployer: deployer.address,
    contracts: {
      IPMarketplace: marketplaceAddress,
      RoyaltyDistributor: royaltyDistributorAddress,
      DerivativeTracker: derivativeTrackerAddress,
    },
    deployedAt: new Date().toISOString(),
  };

  console.log("\n📄 Deployment Summary:");
  console.log(JSON.stringify(deploymentInfo, null, 2));

  console.log("\n✨ All contracts deployed successfully!");
  console.log("\n🔗 Next steps:");
  console.log("1. Verify contracts on block explorer");
  console.log("2. Update frontend configuration with contract addresses");
  console.log("3. Configure Story Protocol integration");
  console.log("4. Initialize marketplace and royalty settings\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
