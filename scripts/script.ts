import { ethers } from "hardhat";


async function main() {

    const name = "BOUNFT";
    const symbol = "BNFT";

    

    const nft = await ethers.deployContract("NFTContract", [name, symbol]);

    await nft.waitForDeployment();

    console.log(
        `eventContract contract successfully deployed to: ${nft.target}`
    );
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});