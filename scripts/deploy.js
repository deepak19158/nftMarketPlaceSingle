const { ethers } = require("hardhat");

const main = async () => {
  const [deployer, addr1] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log(addr1);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Bid = await ethers.getContractFactory("bid");
  // const bid = await Bid.deploy();

  // console.log("deployed at address ", bid.address);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
