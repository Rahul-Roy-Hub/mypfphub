const { ethers } = require("ethers");

const SHAPE_NETWORK = {
    chainId: `0x${Number(11011).toString(16)}`,
    chainName: 'Shape Sepolia',
    nativeCurrency: {
        name: 'ETH',
        symbol: 'ETH',
        decimals: 18,
    },
    rpcUrls: ['https://sepolia.shape.network'],
    blockExplorerUrls: ['https://explorer-sepolia.shape.network'],
};

async function switchToShapeNetwork() {
    const ethereum = window.ethereum;
    if (!ethereum) throw new Error("MetaMask is not installed!");

    try {
        await ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: SHAPE_NETWORK.chainId }],
        });
    } catch (switchError) {
        if (switchError.code === 4902) {
            try {
                await ethereum.request({
                    method: 'wallet_addEthereumChain',
                    params: [SHAPE_NETWORK],
                });
            } catch (addError) {
                console.error('Error adding Shape network:', addError);
                throw addError;
            }
        } else {
            console.error('Error switching to Shape network:', switchError);
            throw switchError;
        }
    }
}

async function connectWallet() {
    const ethereum = window.ethereum;
    if (!ethereum) throw new Error("Please install MetaMask!");

    try {
        const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
        await switchToShapeNetwork();

        const provider = new ethers.BrowserProvider(ethereum);
        const signer = await provider.getSigner();

        return { accounts, signer };
    } catch (error) {
        console.error('Error connecting wallet:', error);
        throw error;
    }
}

module.exports = { SHAPE_NETWORK, switchToShapeNetwork, connectWallet };
