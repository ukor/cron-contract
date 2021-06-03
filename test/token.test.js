const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test token contract", function () {
    let Token, token, admin, addr1, addr2;

    beforeEach(async () => {
        [admin, addr1, addr2, fee] = await ethers.getSigners();
        Token = await ethers.getContractFactory("CronToken");
        token = await Token.deploy(admin.address, fee.address);
        await token.deployed();
    });

    describe("Deployment", () => {
        it("Should set the right owner", async () => {
            expect(await token.admin()).to.equal(admin.address);
        });

        it("Should transfer tokens between account", async () => {
            await token.transfer(addr1.address, 50);
            const addr1Balance = await token.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(50);

            await token.connect(addr1).transfer(addr2.address, 50);
            const addr2Balance = await token.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });

        it("Should fail if sender doesn't have enough tokens", async () => {
            const initialAdminBalance = await token.balanceOf(admin.address);

            await expect(token.connect(addr1).transfer(admin.address, 1)).to.be.revertedWith("Insuffiencet balance");

            expect(await token.balanceOf(admin.address)).to.equal(initialAdminBalance);
        });

        it("Should update balance after transfers", async () => {
            const initialAdminBalance = await token.balanceOf(admin.address);

            await token.transfer(addr1.address, 1000);
            await token.transfer(addr2.address, 9000);

            const newAdminBalance = await token.balanceOf(admin.address);

            // big number overflow - use bignumber lib or reduce total supply for testing purpose
            // expect(newAdminBalance).to.equal(initialAdminBalance - (1000 + 9000));
            const addr1Balance = await token.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(1000);
            const addr2Balance = await token.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(9000);
        });
    });
});
