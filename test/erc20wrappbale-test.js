const { expect, use, util } = require("chai");
const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
use(solidity);

describe("Eth9 Test", function () {
  let erc20Wrappable, addr1, addr2, addr3, addr4;

  beforeEach(async () => {
    [addr1, addr2, addr3, addr4] = await ethers.getSigners();
    const ERC20Wrappable = await ethers.getContractFactory("ERC20WrappableSupport");
    erc20Wrappable = await ERC20Wrappable.deploy();
    await erc20Wrappable.deployed();

    const TestWrap = await ethers.getContractFactory("TestWrap");
    testWrap = await TestWrap.deploy();
    await testWrap.deployed();

    const Weth9 = await ethers.getContractFactory("WETH9");
    weth9 = await Weth9.deploy();
    await weth9.deployed();
  });

  it("Initialize", async function () {
    expect(erc20Wrappable).to.be.ok;
    expect(testWrap).to.be.ok;
    expect(weth9).to.be.ok;
  });

  it("Token address", async function () {
    await testWrap.setWToken(weth9.address);
    expect(await testWrap.wToken()).to.equal(weth9.address);

    await testWrap.connect(addr1).pay({value: ethers.utils.parseEther("20")});
    //approve first
    await weth9.connect(addr1).approve(testWrap.address,ethers.utils.parseEther("20"));
    // next refondMe
    await testWrap.refondMe(10);
  });
});
