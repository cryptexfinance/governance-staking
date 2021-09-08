require("dotenv").config();

import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "hardhat-deploy";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const mnemonic = process.env.DEPLOYER_MNEMONIC as string;

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
			accounts: { mnemonic: mnemonic },
		},
		rinkeby: {
			url: process.env.RINKEBY_API_URL,
			accounts: { mnemonic: mnemonic },
		},
	},
};
export default config;
