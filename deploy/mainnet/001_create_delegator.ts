import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { deployments, hardhatArguments } from "hardhat";
import "hardhat-deploy/dist/src/type-extensions";

const delegator: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	if (hardhatArguments.network === "mainnet") {
		console.log("=====Mainnet Deploy=====");
		const delegatorFactory = await deployments.getOrNull("DelegatorFactory");
		const { log } = deployments;
		if (delegatorFactory) {
			const namedAccounts = await hre.getNamedAccounts();
			// @ts-ignore
			let delegatorFactoryContract = await hre.ethers.getContract(
				"DelegatorFactory",
				namedAccounts.deployer
			);

			let accounts = [
				"0xf71e9c766cdf169edfbe2749490943c1dc6b8a55", // test account
				"0xD27e8256196d6f794c4329644C225b7b81a260f7", //David Nowak / Huntsman
				"0xA36baB9f9e2392c00A2251caF382f5559C00f4De", // DesertDwelr
				"0x2CE2b820Ad940dD3C332768C1cB9ebc72F961b16", // David R Jennings
				"0xd0fb37Cde4a7F688eD14f674414912F21B8148DB", // Joshua Britt
				"0x767D222a509D107522e50161CA17FfCF0e5AA3dE", // leo
				"0x9b6812bf787b814cd2aa13d319a371eac5dff49b", // Indigo
				"0x097c39e5e576a8706404cd0d81e05b522f5bcaff", // dnkta.eth
				"0x332Ef2ADC9e6d980b05A89901F3f29D0464442c5", // scottie33
				"0x85Eb872c4274Df8b9e596B3BBa490B205D79122E", // TheyCallMeJim
				"0xC3c5ac9C328323e53DbdF064D94779436B91C49A", // Mr. Brightside
				"0x564bca365d62bcc22db53d032f8dbd35439c9206", // brajon
				"0x4CbAeDF625d236EC66e2dc47e7E139b1e79677Da", // MediumArchibald
			];

			for (let i = 0; i < accounts.length; i++) {
				const isCreated = await delegatorFactoryContract.delegateeToDelegator(accounts[i]);
				if (isCreated == "0x0000000000000000000000000000000000000000") {
					await delegatorFactoryContract.createDelegator(accounts[i]);
					console.log("Delegator Created for:", accounts[i]);
					const delegatorAddress = await delegatorFactoryContract.delegateeToDelegator(accounts[i]);
					console.log("With Address: ", delegatorAddress);
				} else {
					console.log("Delegator already created for", accounts[i]);
					console.log("With Address: ", isCreated);
				}
			}
		} else {
			log("Delegator Factory not created");
		}
	}
};

export default delegator;
