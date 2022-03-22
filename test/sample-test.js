const { expect, use } = require("chai");
const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
use(solidity);

describe("Token Test", function () {

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

describe("TokenSale Test", function () {
  let TokenSale, tokenSale, toTransfer, ERC20Token, addr1, addr2, addr3, addr4;

  beforeEach(async () => {
    [addr1, addr2, addr3, addr4] = await ethers.getSigners();
    toTransfer = ethers.utils.parseEther("1");
    TokenSale = await ethers.getContractFactory("TokenSale");
    tokenSale = await TokenSale.deploy();
    await tokenSale.deployed();
    ERC20Token = await tokenSale.token();
  });

  it("Initialize", async function () {
    expect(tokenSale).to.be.ok;
  });

  it("Should be equal token balance", async function () {
   await tokenSale.connect(addr1).deposit({from: addr1.address, value: toTransfer});
    
    expect(await tokenSale.userBalance(addr1.address)).to.deep.equal(toTransfer);
    expect(await tokenSale.whitelist(addr1.address)).to.equal(true);
  });

  it("Twice deposit test", async function () {
    await tokenSale.connect(addr1).deposit({from: addr1.address, value: toTransfer});
    await tokenSale.connect(addr2).deposit({from: addr2.address, value: toTransfer});
    await tokenSale.connect(addr1).deposit({from: addr1.address, value: toTransfer});
     
     expect(await tokenSale.userBalance(addr1.address)).to.equal(ethers.utils.parseEther("2"));
     expect(await tokenSale.userBalance(addr2.address)).to.equal(ethers.utils.parseEther("1"));
     expect(await tokenSale.whitelist(addr1.address)).to.equal(true);
     expect(await tokenSale.whitelist(addr2.address)).to.equal(true);
   });

   it("TokenSale contract balance test", async function () {
    await tokenSale.connect(addr1).deposit({from: addr1.address, value: toTransfer});
    await tokenSale.connect(addr2).deposit({from: addr2.address, value: toTransfer});
    await tokenSale.connect(addr1).deposit({from: addr1.address, value: toTransfer});

    expect(await ethers.provider.getBalance(tokenSale.address)).to.equal(ethers.utils.parseEther("3"));
   });

   it("Set exchange rate", async function () {
    await tokenSale.setExchangeRate(5);

    expect(await tokenSale.exchangeRate()).to.equal(5);
   });
});
