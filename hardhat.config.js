require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

task("accounts", "Prints the list of account", async () => {
    const accounts = await ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// Alchemy or INFURA
const URL = "https://eth-ropsten.alchemyapi.io/v2/Qs2zlM_1VojOewCY5Rnxf4ePcl3V5kGe";
const ADMIN_PRIVATE_KEY = "0xedc66d956cc82795120b767239875215b500a54698124c48b1c9149d580a5e2a";
const FEE_PRIVATE_KEY = "0xdbb8349b5bcccfaf931b3cd521bf012fb362f64721dde083dd64480d10de3799";

module.exports = {
    solidity: "0.8.1",
    networks: {
        ropsten: {
            url: URL,
            accounts: [ADMIN_PRIVATE_KEY, FEE_PRIVATE_KEY],
        },
    },
};
