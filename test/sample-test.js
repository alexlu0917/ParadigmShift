const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AxleToken", function () {
  it("Should return corect name and symbol", async function () {
    const AxleToken = await ethers.getContractFactory("AxleToken");
    const axleToken = await AxleToken.deploy();
    await axleToken.deployed();

    console.log('token name', await axleToken.name());
    expect(await axleToken.name()).to.equal("Axle");

    console.log('token symbol', await axleToken.symbol());
    expect(await axleToken.symbol()).to.equal("AXL");
  });
});
