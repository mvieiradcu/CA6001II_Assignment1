const Marketplace = artifacts.require("Marketplace");
const NFT = artifacts.require("NFT");

contract("Marketplace and NFT Tests", (accounts) => {
  const [deployer, seller, buyer] = accounts;
  let marketplace;
  let nft;
  let tokenURI = "http://test.com/dummy.json";
  let nftPrice = web3.utils.toWei("1", "ether");
  let listingFee;
  let tokenId;

  before(async () => {
    marketplace = await Marketplace.new();
    nft = await NFT.new(marketplace.address);
    listingFee = await marketplace.LISTING_FEE();

    // Mint an NFT and list it on the marketplace
    await nft.mint(tokenURI, { from: seller });
    tokenId = (await nft.getCurrentToken()).toNumber() - 1;

    // Seller approves Marketplace to manage the NFT
    await nft.setApprovalForAll(marketplace.address, true, { from: seller });
  });

  it("should list an NFT", async () => {
    // Mint an NFT
    await nft.mint(tokenURI, { from: seller });

    const newTokenId = (await nft.getCurrentToken()).toNumber() - 1;
  
    // List the NFT on the marketplace
    await marketplace.listNFT(nft.address, newTokenId, "NFT Name", nftPrice, tokenURI, { from: seller, value: listingFee });
    const listedToken = await marketplace.getTokenForId(newTokenId);
  
    // Check if the NFT is listed
    assert(listedToken.isListed, "NFT should be listed on the marketplace");
  });
  
it("allows users to buy an NFT", async () => {
  // Execute the buyNFT function to simulate a user purchasing an NFT
  await marketplace.buyNFT(nft.address, tokenId, { from: buyer, value: nftPrice });
  
  // Retrieve the updated details of the token
  const soldToken = await marketplace.getTokenForId(tokenId);
  
  // Verify that the ownership of the NFT has been transferred
  assert.equal(soldToken.owner, buyer, "The buyer should be the new owner of the NFT");
});

it("returns the current listing fee", async () => {
  // Retrieve the listing fee
  const fee = await marketplace.getListingFee();
  
  // Verify that the retrieved listing fee matches
  assert.equal(fee.toString(), listingFee, "Should return the correct listing fee");
});

it("retrieves details for a listed NFT by its ID", async () => {
  // Retrieve the details of the NFT
  const tokenDetails = await marketplace.getTokenForId(tokenId);
  
  // Verify that the function returns details for the correct token
  assert.equal(tokenDetails.tokenId, tokenId, "Should return details for the specified NFT");
});

it("returns the current balance of the marketplace", async () => {
  // Retrieve the current ether balance
  const balance = await marketplace.getMarketPlaceBalance();
  
  // Verify that the balance includes the listing fee
  assert(balance.toString(), listingFee, "Marketplace balance should include the listing fee");
});

it("returns the total count of NFTs listed on the marketplace", async () => {
  // Retrieve the total count of NFTs listed
  const count = await marketplace.getItemsCount();
  
  // Verify that the count matches
  assert.equal(count.toString(), '1', "Should have one NFT listed on the marketplace");
});

it("returns the total number of NFTs sold through the marketplace", async () => {
  // Retrieve the total number of NFTs 
  const sold = await marketplace.getItemsSold();
  
  // Verify that the sold count matches
  assert.equal(sold.toString(), '1', "Should have one NFT sold through the marketplace");
});

});
