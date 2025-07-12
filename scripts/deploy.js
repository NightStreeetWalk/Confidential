const hre = require("hardhat");

async function main() {
  const candidateCount = 3; // Example: 3 candidates
  const ConfidentialVoting = await hre.ethers.getContractFactory("ConfidentialVoting");
  const voting = await ConfidentialVoting.deploy(candidateCount);

  await voting.deployed();
  console.log("ConfidentialVoting deployed to:", voting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
