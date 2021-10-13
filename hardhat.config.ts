require("dotenv").config();

import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const mnemonic = process.env.TEST_MNEMONIC as string;
const deployerMnemonic = process.env.DEPLOYER_MNEMONIC as string;
const etherscanApi = process.env.ETHERSCAN_API_KEY as string;

const config: HardhatUserConfig = {
	//@ts-ignore
	namedAccounts: {
		deployer: {
			default: 0, // here this will by default take the first account as deployer
		},
	},
	solidity: {
		version: "0.8.6",
		settings: {
			optimizer: {
				enabled: true,
				runs: 999999,
			},
		},
	},
	paths: {
		sources: "./src",
		tests: "./src/test",
		cache: "./cache",
		artifacts: "./artifacts",
	},
	networks: {
		hardhat: {
			forking: {
				url: process.env.MAINNET_API_URL as string,
			},
		},
		mainnet: {
			url: process.env.MAINNET_API_URL,
			accounts: { mnemonic: deployerMnemonic },
		},
		rinkeby: {
			url: process.env.RINKEBY_API_URL,
			accounts: { mnemonic: mnemonic },
		},
	},
	etherscan: {
		// Your API key for Etherscan
		// Obtain one at https://etherscan.io/
		apiKey: etherscanApi,
	},
};
export default config;
