const { assert, expect } = require("chai")
const { deployments, ethers, getNamedAccounts } = require("hardhat")

describe("FundMe", async function() {
    let fundMe, deployer, mockV3Aggregator
    beforeEach(async function() {
        // Deploy our FundMe contract using hardhat-deploy
        deployer = (await getNamedAccounts()).deployer
        await deployments.fixture(["all"])
        fundMe = await ethers.getContract("FundMe", deployer)
        mockV3Aggregator = await ethers.getContract(
            "MockV3Aggregator",
            deployer
        )
    })

    describe("constructor", async function() {
        it("sets the aggregator addresses correctly", async function() {
            const aggregatorAddress = await fundMe.priceFeed()
            assert.equal(aggregatorAddress, mockV3Aggregator.address)
        })
        it("sets the deployer as owner", async function() {
            const owner = await fundMe.iOwner()
            assert.equal(owner, deployer)
        })
    })

    describe("fund", async function() {
        it("fails if you don't send enough ETH", async function() {
            await expect(fundMe.fund()).to.be.revertedWith("Didn't send enough")      
        })
    })
})
