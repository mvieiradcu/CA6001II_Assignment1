const NFT = artifacts.require("NFT");

contract("NFT Contract Tests", (accounts) => {
  const [deployer, minter] = accounts;

  it("Should mint an NFT successfully", async () => {
    const nft = await NFT.new(deployer); 
    const tokenURI = "http://test.com/nft.json";
    
    // Mint an NFT
    await nft.mint(tokenURI, { from: minter });

    // Retrieve token ID
    const currentTokenId = await nft.getCurrentToken();

    // Retrieve the token URI
    const mintedTokenURI = await nft.tokenURI(currentTokenId.subn(1));

    // Assertions
    assert.equal(mintedTokenURI, tokenURI, "The tokenURI of the minted NFT does not match the expected value.");
  });

  it("Should return the correct token ID", async () => {
    const nft = await NFT.new(deployer); 
    const tokenURI1 = "http://test.com/nft1.json";
    const tokenURI2 = "http://test.com/nft2.json";
    
    // Mint two NFTs
    await nft.mint(tokenURI1, { from: minter });
    await nft.mint(tokenURI2, { from: minter });

    // Retrieving token ID
    const currentTokenId = await nft.getCurrentToken();

    //Assert that there are 2 NFTs minted
    assert.equal(currentTokenId.toString(), '2', "The current token ID does not match the expected value.");
  });
});
