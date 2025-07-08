import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

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
  paths: {
    sources: "./contracts",
    tests: "./test-hardhat",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};

export default config;
