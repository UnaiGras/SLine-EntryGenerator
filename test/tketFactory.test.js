const {assert, expect} = require("chai")
require("mocha")
const {ethers} = require("hardhat")




describe("Testing", function () {

        beforeEach("Deploying...", async function () {

            const accounts = await ethers.getSigners()
            const deployer = accounts[0]

            const FeeReceipient = ethers.getContract("FeeReceiient", deployer)
            console.log("SellerContract is deployed at: ",FeeReceipient.address)

            const TiketGenerator = ethers.getContractAt(
                "TiketFactory", 
                deployer
            )
            console.log("TiketGenerator is deployed at: ",TiketGenerator.address)


        })
        describe("Set contructor values", function () {

            it("Should set the correct values", async () => {
                const mintResponse = await TiketGenerator.mintFee()
                const feeResponse = await TiketGenerator.feeReceipient()
                const platformResponse = await TiketGenerator.platformFee()

                assert.equal(platformResponse, 1)
                assert.equal(mintResponse, 3)
                assert.equal(feeResponse, FeeReceipient.address)

            })
        })
})