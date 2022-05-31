require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");

require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const PRIVATEKEY = "";
const INFURAKEY = ""

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
// module.exports = {
//   solidity: "0.7.3",
// };

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  defaultNetwork: "testnet",
  etherscan: {
    apiKey: process.env.BSCSCAN_API_KEY
  },
  networks: {
    // localhost: {
    //   url: "http://127.0.0.1:8545",
    //   gasPrice: 20000000000,
    //   accounts: [process.env.PRIVATEKEY]
    // },
    // hardhat: {
    // },
    testnet: {
      url: `https://rinkeby.infura.io/v3/${INFURAKEY}`,
      chainId: 4,
      gas: 2100000,
      gasPrice: 8000000000,
      accounts: [PRIVATEKEY]
    },
    // mainnet: {
    //   url: "https://bsc-dataseed.binance.org/",
    //   chainId: 56,
    //   gasPrice: 20000000000,
    //   accounts: [process.env.PRIVATEKEY]
    // }
  },
  solidity: {
    compilers: [
      // {
      //   version: "0.5.16"
      // },
      // {
      //     version: "0.7.0"
      // },
      // {
      //   version: "0.7.3"
      // },
      {
        version: "0.8.7"
      }
    ],
    settings: {
      optimizer: {
        enabled: true
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
};
