import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "hardhat-gas-reporter";
import "solidity-coverage";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    "story-testnet": {
      url: process.env.STORY_RPC_URL || "https://rpc.odyssey.storyrpc.io",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 1513,
    },
    "story-mainnet": {
      url: process.env.STORY_MAINNET_RPC_URL || "https://rpc.story.foundation",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 1514,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      "story-testnet": process.env.STORY_EXPLORER_API_KEY || "",
      "story-mainnet": process.env.STORY_EXPLORER_API_KEY || "",
    },
    customChains: [
      {
        network: "story-testnet",
        chainId: 1513,
        urls: {
          apiURL: "https://api-odyssey.storyscan.xyz/api",
          browserURL: "https://odyssey.storyscan.xyz",
        },
      },
      {
        network: "story-mainnet",
        chainId: 1514,
        urls: {
          apiURL: "https://api.storyscan.xyz/api",
          browserURL: "https://storyscan.xyz",
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;
