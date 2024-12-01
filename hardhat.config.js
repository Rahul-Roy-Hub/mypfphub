require("@nomicfoundation/hardhat-toolbox-viem");
require('@nomicfoundation/hardhat-ethers');
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

module.exports = {
  solidity: "0.8.27",
  networks: {
    shapeSepolia: {
      url: process.env.ALCHEMY_TESTNET_RPC_URL,
      chainId: 11011,
      accounts: [PRIVATE_KEY],
    },
    // ... other networks
  },
};
