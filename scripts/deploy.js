const {ethers} = require("hardhat")

async function main() {

  let prevUserBalance;
  const value = ethers.utils.parseEther("1");
	const [deployer] = await ethers.getSigners();

	console.log(
	"Deploying contracts with the account:",
	deployer.address
	);

  prevUserBalance = deployer.getBalance(); 

	console.log("Account balance:", (deployer.getBalance().toString()));


	const addressesChest = await ethers.getContractFactory(
    "AddressesChest"
  );
  const validTokens = await ethers.getContractFactory(
    "ValidTokens"
  );
  const feeReceipient = await ethers.getContractFactory(
    "FeeReceipient"
  );
  const tiketFactory = await ethers.getContractFactory(
    "TiketFactory"
  );

  const AddressesChest = await addressesChest.deploy();
  const ValidTokens = await validTokens.deploy();
	const FeeReceipient = await feeReceipient.deploy();

  const TiketFactory = await tiketFactory.deploy(
    1,
    FeeReceipient.address,
    3
  );
  console.log("------------------------------------------------------")
  console.log("AddressesChest deployed at:", AddressesChest.address);
  console.log("ValidTokens deployed at:", ValidTokens.address);
  console.log("FeeReceipient deployed at:", FeeReceipient.address);
  console.log("TiketFactory deployed at:", TiketFactory.address);
  console.log("------------------------------------------------------")
  
  








}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });