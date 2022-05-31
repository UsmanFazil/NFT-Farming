// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Staking = await hre.ethers.getContractFactory("ShoefyFarm");
  const Shoetoken = "0x8F973d1C33194fe773e7b9242340C3fdB2453b49"; // rinkeby testnet shoe token address
  const ShoeNFT = "0xD6afeFc8107185dAC6d99F0cfb34B3D97ff938e7"; // rinkeby testnet shoe nft contract address
  const categories = ["common", "unique", "rare", "epic", "legendary", "mythic-god", "mythic-devil", "mythic-alien"];
  const totalGeneralNFTs = [100,100,100,100,100,100,100,100];
  const totalRapidNFTs = [100,100,100,100,100,100,100,100];
  const generalFarmTimes_ = [1000, 1000,1000,1000, 1000,1000,1000,1000];
  const rapidFarmtimes_ = [1000, 1000,1000,1000, 1000,1000,1000,1000];
  const generalTokensRequired_ = ["100000000000000000", "100000000000000000","100000000000000000","100000000000000000", "100000000000000000","100000000000000000","100000000000000000","100000000000000000"];
  const rapidTokensRequired_ =["100000000000000000", "100000000000000000","100000000000000000","100000000000000000", "100000000000000000","100000000000000000","100000000000000000","100000000000000000"];
  const SignerAddress = "0x6950B412620ebc79943739e57Aa9bc80f2aF89cA";
  
  const staking = await Staking.deploy(Shoetoken,ShoeNFT,categories, totalGeneralNFTs, totalRapidNFTs,generalFarmTimes_, rapidFarmtimes_, 
        generalTokensRequired_, rapidTokensRequired_, SignerAddress );

  await staking.deployed();

  console.log("Staking deployed to:", staking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
