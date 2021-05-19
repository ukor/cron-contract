const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("test Vault contract", function () {
    let Token, token, owner, addr1, addr2;

    beforeEach(async () => {
        [owner, addr1, addr2, _] = await ethers.getSigners();
        Token = await ethers.getContractFactory("VaultContract");
        token = await Token.deploy(owner.address);
        await token.deployed();
    });

    describe("Deployment", () => {
        it("Should set the right owner", async () => {
            expect(await token.owner()).to.equal(owner.address);
        });
    });
});
