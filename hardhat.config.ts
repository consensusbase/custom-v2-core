import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 999999
          },
          evmVersion: "istanbul"
        }
      },
      {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 999999
          }
        }
      }
    ]
  },
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      chainId: 1337,
      accounts: ['']
    },
    sepolia: {
      url: "",
      chainId: 11155111,
      accounts: ['']
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test-hardhat",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};

export default config;
