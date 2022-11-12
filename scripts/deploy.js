const {ethers} = require("hardhat")

async function main() {

  let prevUserBalance;
  let finalUserBalance;

	const [deployer] = await ethers.getSigners();

	console.log(
	"Deploying contracts with the account:",
	deployer.address
	);

  prevUserBalance = deployer.getBalance().toString(); 

	console.log("Account balance:", (deployer.getBalance().toString()));

	const feeReceipient = await ethers.getContractFactory(
    "FeeReceipient"
  );
	const FeeReceipient = await feeReceipient.deploy();

  const ReceipientAddress = FeeReceipient.address.toString()
	console.log("FeeReceipient deployed at:", ReceipientAddress);

  const tiketFactory = await ethers.getContractFactory(
    "TiketFactory"
  );
  const TiketFactory = await tiketFactory.deploy(
    1,
    ReceipientAddress,
    3
  );

  finalUserBalance = deployer.getBalance().toString(); 
  console.log("TiketFactory deployed at:", TiketFactory.address);

  console.log("The cost of deploying was:", prevUserBalance - finalUserBalance);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
	console.error(error);
	process.exit(1);
  });