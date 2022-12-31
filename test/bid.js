const { expect } = require("chai");
// const { ethers } = require("hardhat");
// const { ethers } = require("hardhat");

describe("bid contract", () => {
  let deployedBid;
  let deployedNft;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let admin;
  let nftOwner;
  const provider = ethers.getDefaultProvider();

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    bidContract = await ethers.getContractFactory("bid");
    nftContract = await ethers.getContractFactory("nft");

    deployedBid = await bidContract.deploy();
    deployedNft = await nftContract.deploy();

    admin = await deployedBid.admin();
    nftOwner = await deployedNft.owner();
  });

  describe("deploy the contract", () => {
    it("check the owner", async () => {
      expect(admin).to.equal(owner.address);
      expect(nftOwner).to.equal(nftOwner);
    });

    beforeEach(async () => {
      await deployedNft.safeMint(owner.address, 1);
      await deployedNft.approve(deployedBid.address, 1);
      await deployedBid.nft_list(deployedNft.address, 4, 1);
    });

    describe("minitng listing", () => {
      it("minting the nft to the owner and approving", async () => {
        expect(await deployedNft.ownerOf(1)).to.equal(owner.address);
        expect(await deployedNft.getApproved(1)).to.equal(deployedBid.address);
      });

      it("listing the nft", async () => {
        expect(
          (await deployedBid.nft(deployedBid.getKey(deployedNft.address, 1)))
            .owner
        ).to.equal(owner.address);

        expect(
          (await deployedBid.nft(deployedBid.getKey(deployedNft.address, 1)))
            .price
        ).to.equal(4);

        expect(
          (await deployedBid.nft(deployedBid.getKey(deployedNft.address, 1)))
            .tokenId
        ).to.equal(1);
      });

      it("buying the nft directly", async () => {
        await deployedBid
          .connect(addr1)
          .buy(deployedNft.address, 1, { value: 4 });
        // expect()

        expect(await deployedNft.ownerOf(1)).to.equal(addr1.address);
      });
    });

    describe("playing the game", () => {
      it("starting the game", async () => {
        await deployedBid
          .connect(addr1)
          .start(deployedNft.address, 1, { value: 3 });

        await deployedBid
          .connect(addr2)
          .start(deployedNft.address, 1, { value: 3 });

        expect(
          (await deployedBid.nft(deployedBid.getKey(deployedNft.address, 1)))
            .recieved
        ).to.equal(6);
      });

      it("deciding winner", async () => {
        await deployedBid
          .connect(addr1)
          .start(deployedNft.address, 1, { value: 3 });

        await deployedBid
          .connect(addr2)
          .start(deployedNft.address, 1, { value: 3 });

        await deployedBid.winner(addr1.address, deployedNft.address, 1);

        expect(await deployedNft.ownerOf(1)).to.equal(addr1.address);
        expect(await deployedBid.balance()).to.equal(6);
      });
    });
  });
});
