const { ethers } = require("hardhat");

async function main() {
    const [deployer, fee] = await ethers.getSigners();

    console.log(`Deploying contracts with the account: ${deployer.address}`);

    const balance = await deployer.getBalance();
    console.log(`Deployer account balace: ${balance.toString()}`);

    const Token = await ethers.getContractFactory("CronToken");
    const token = await Token.deploy(deployer.address, fee.address);
    await token.deployed();
    console.log(`Token address: ${token.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    });
