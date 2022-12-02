const { ethers } = require("hardhat");

const { LINK_TOKEN, VRF_COORDINATOR, KEY_HASH, FEE } = require("../constants");

const main = async () => {
  const contract = await ethers.getContractFactory("RandomWinnerGame");

  /* ############ START => Additional Deployement Steps (Optional) ######################## */
  // {
  //   const gasPrice = await contract.signer.getGasPrice();
  //   console.log(`Current gas price: ${gasPrice}`);
  //   const estimatedGas = await contract.signer.estimateGas(
  //     contract.getDeployTransaction(VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE) //need to change based upon contract's constructor
  //   );
  //   console.log(`Estimated gas: ${estimatedGas}`);
  //   const deploymentPrice = gasPrice.mul(estimatedGas);
  //   const deployerBalance = await contract.signer.getBalance();
  //   console.log(
  //     `Deployer balance:  ${ethers.utils.formatEther(deployerBalance)}`
  //   );
  //   console.log(
  //     `Deployment price:  ${ethers.utils.formatEther(deploymentPrice)}`
  //   );
  //   if (Number(deployerBalance) < Number(deploymentPrice)) {
  //     throw new Error("You dont have enough balance to deploy.");
  //   }
  // }
  /* ############ END   => Additional Deployement Steps (Optional) ######################## */

  const deployedContract = await contract.deploy(
    VRF_COORDINATOR,
    LINK_TOKEN,
    KEY_HASH,
    FEE
  );
  await deployedContract.deployed();

  console.log(
    "RandomWinnerGame contract address is: ",
    deployedContract.address
  );

  console.log(
    "Holding the process for 30 seconds ...please wait for the contract to become available on etherscan!"
  );
  await wait(30);

  await hre.run("verify:verify", {
    address: deployedContract.address,
    constructorArguments: [VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE],
  });
};

const wait = async (seconds) => {
  return new Promise((resolve) => {
    setTimeout(resolve, seconds * 1000);
  });
};

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
