/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const {
  etherapikey,
  GOERLI_PRIVATE_KEY,
  ALCHEMY_API_KEY,
} = require("./secrets.json");

// require("@nomicfoundation/hardhat-toolbox");

// const ALCHEMY_API_KEY = "kr1kVAS77uczomI5smYkfFctQitYXoJt";

// const GOERLI_PRIVATE_KEY =
//   "5c979872ddc6d1044116ea78f1d4473b1462f2c72481aa8e837f94d4c404f322";

// const etherapikey = "73DIK4MUWME4X5UDJ8IWC46XPNK1NI595C";

module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY],
    },
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: etherapikey,
  },
};
