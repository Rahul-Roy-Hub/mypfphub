const { ethers } = require("ethers");
const { SHAPE_NETWORK } = require("../src/utils/network");
require("dotenv").config(); // Load environment variables from a `.env` file

async function main() {
    // Make sure we're on the right network
    const provider = new ethers.JsonRpcProvider("https://sepolia.shape.network");
    const network = await provider.getNetwork();
    if (network.chainId !== BigInt(SHAPE_NETWORK.chainId)) {
        throw new Error(`Please switch to Shape Sepolia network (Chain ID: ${SHAPE_NETWORK.chainId})`);
    }

    // Load private key and ensure it's set
    const privateKey = process.env.PRIVATE_KEY;
    if (!privateKey) {
        throw new Error("Missing PRIVATE_KEY environment variable");
    }
    const signer = new ethers.Wallet(privateKey, provider);

    // Compile and deploy the contract
    const contractArtifact = require("../artifacts/contracts/MYPFPHub.sol/MYPFPHub.json");
    const factory = new ethers.ContractFactory(contractArtifact.abi, contractArtifact.bytecode, signer);

    console.log("Deploying contract...");
    const initialOwner = signer.address; // Pass the deployer's address as the initialOwner
    const contract = await factory.deploy(initialOwner);
    console.log("Waiting for contract to be mined...");
    await contract.deploymentTransaction().wait();

    console.log(`Contract deployed to: ${contract.target}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
