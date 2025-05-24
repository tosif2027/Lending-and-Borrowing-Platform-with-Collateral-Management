const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying LendingPlatform contract with account:", deployer.address);

  const LendingPlatform = await hre.ethers.getContractFactory("LendingPlatform");

  const collateralTokenAddress = "0xYourCollateralTokenAddress";
  const loanTokenAddress = "0xYourLoanTokenAddress";

  const lendingPlatform = await LendingPlatform.deploy(collateralTokenAddress, loanTokenAddress);

  await lendingPlatform.deployed();

  console.log("LendingPlatform deployed to:", lendingPlatform.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
