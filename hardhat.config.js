require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("@nomiclabs/hardhat-etherscan")
require("dotenv").config()
require("hardhat-deploy")
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
/**
 * @type import('hardhat/config').HardhatUserConfig
 */


const PRIVATE_KEY =
    process.env.PRIVATE_KEY 
const ALCHEMY_KEY = process.env.ALCHEMY_KEY
const ETHERSCAN_API_KEY= process.env.ETHERSCAN_API_KEY

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
            // gasPrice: 130000000000,
        },
        //goerli: {
        //    url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_KEY}`,
        //    accounts:[PRIVATE_KEY],
        //},
    },
    solidity: {
        compilers: [
            {
                version: "0.8.17"
            },
            {
                version: "0.8.0"
            },
            {
                version: "0.8.4"
            },
            {
                version: "0.6.6"
            },
        ],
    },
    //etherscan: {
    //    apiKey: ETHERSCAN_API_KEY,
    //},
    gasReporter: {
        enabled: true,
        currency: "USD",
        outputFile: "gas-report.txt",
        noColors: true,
        // coinmarketcap: COINMARKETCAP_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0,
            1: 0, 
        },
    },
    mocha: {
        timeout: 500000,
    },
}