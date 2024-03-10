// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";


contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address marketplaceContract;
    event NFTMinted(uint256);

    /**
     * @dev Constructor to create a new NFT contract instance. It initializes the ERC721 token
     * with a name and a symbol and sets the marketplace address where these NFTs can be sold.
     *
     * @param _marketplace The address of the marketplace contract that will be allowed to manage
     * the NFTs minted from this contract. This enables the marketplace to list and sell the NFTs.
     */
    constructor(address _marketplace) ERC721("MyToken", "MTKN") {
        marketplaceContract = _marketplace;
    }

    /**
     * @dev Mints a new NFT with the provided metadata URI. This function assigns a new unique
     * token ID to the minted NFT, sets its metadata URI, approves the marketplace contract to
     * manage the NFT on behalf of the token owner, and increments the token ID counter for the
     * next token to be minted. Finally, it returns the ID of the newly minted token.
     *
     * @param _tokenURI The metadata URI for the newly minted NFT.
     * @return uint256 The ID of the newly minted token.
     */
    function mint(string memory _tokenURI) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);

        _setTokenURI(newItemId, _tokenURI);
        setApprovalForAll(marketplaceContract, true);
        _tokenIds.increment();
        return _tokenIds.current();
    }

    /**
     * @dev Retrieves the current token ID counter's value. This function is useful for
     * understanding how many tokens have been minted by this contract so far, as it returns
     * the ID that will be assigned to the next minted token.
     *
     * @return uint256 The current value of the token ID counter, representing the total number
     * of tokens minted by this contract.
     */
    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }
}
