import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { deployments, hardhatArguments } from "hardhat";
import "hardhat-deploy/dist/src/type-extensions";
import { BigNumber } from "ethers";

const delegatorFactory: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	if (hardhatArguments.network === "rinkeby") {
		console.log("=====Rinkeby Deploy=====");
		const delegatorFactory = await deployments.getOrNull("DelegatorFactory");
		const { log } = deployments;
		if (!delegatorFactory) {
			const namedAccounts = await hre.getNamedAccounts();

			const governanceToken = "0xAa715DbD2ED909B7B7727dC864F3B78276D14A19"; // CTX
			const waitTime = 604800; // 7 days
			const guardian = "0xf77E8426EceF4A44D5Ec8986FB525127BaD32Fd1"; // Multi sign

			const delegatorFactoryDeployment = await deployments.deploy("DelegatorFactory", {
				contract: "DelegatorFactory",
				from: namedAccounts.deployer,
				args: [governanceToken, governanceToken, waitTime, guardian],
				skipIfAlreadyDeployed: true,
				maxFeePerGas: BigNumber.from(110000000000), //110 GWEI
				maxPriorityFeePerGas: BigNumber.from(1000000000), //1 GWEI
				log: true,
			});
			log(
				`DelegatorFactory deployed at ${delegatorFactoryDeployment.address} for ${delegatorFactoryDeployment.receipt?.gasUsed}`
			);
		} else {
			log("DelegatorFactory already deployed");
		}
	}
};

export default delegatorFactory;
