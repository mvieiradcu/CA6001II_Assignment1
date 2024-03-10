// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./@openzeppelin/contracts/utils/Counters.sol";
import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    // Utilize OpenZeppelin's Counters library for secure counter management
    using Counters for Counters.Counter;
    Counters.Counter private _nftsSold; // Counter for the number of NFTs sold
    Counters.Counter private _nftCount; // Counter for the number of NFTs listed
    uint256 public LISTING_FEE = 1.0 ether; // Listing fee for each NFT
    address payable private _marketOwner; // Owner of the marketplace, receives listing fees
    // Mapping from NFT token ID to its details, storing all listed NFTs
    mapping(uint256 => Token) private _idToToken;

    // Struct to store details about each NFT
    struct Token {
        address nftContract; // Contract address of the NFT
        uint256 tokenId; // Unique token ID of the NFT
        address payable seller; // Seller's address
        address payable owner; // Current owner's address
        string tokenURI; // URI for token metadata
        string name; // Name of the token
        uint256 price; // Price of the NFT in Wei
        bool isListed; // Flag to indicate if the NFT is listed for sale
        uint256 listingTime; // Add listing time

    }

    // Event emitted when an NFT is listed on the marketplace
    event NFTListed(
        address nftContract,
        uint256 tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 listingTime 
    );
    // Event emitted when an NFT is sold
    event NFTSold(
        address nftContract,
        uint256 tokenId,
        address seller,
        address owner,
        uint256 price
    );

    // Constructor sets the deployer as the market owner
    constructor() {
        _marketOwner = payable(msg.sender);
    }

    /**
     * @dev Lists an NFT on the marketplace by transferring it from the seller to the contract.
     * Requires the transaction value to be equal to the listing fee to ensure commitment from the seller.
     * Upon successful listing, increments the count of NFTs listed and emits an NFTListed event.
     *
     * @param _nftContract The address of the ERC721 NFT contract.
     * @param _tokenId The unique identifier for the NFT.
     * @param _name The name of the NFT.
     * @param _tokenURI The metadata URI for the NFT.
     *
     * Requirements:
     * - The transaction value must be greater than 0, ensuring a non-zero price for listing.
     * - The transaction value must equal the predefined listing fee.
     * - The caller must own the NFT or be an approved operator for the `_tokenId` in the NFT contract.
     */
    function listNFT(
        address _nftContract,
        uint256 _tokenId,
        string memory _name,
        uint256 _price,
        string memory _tokenURI
    ) public payable nonReentrant {
        require(msg.value > 0, "Price must be at least 1 wei");
        require(msg.value == LISTING_FEE, "Not enough ether for listing fee");

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        _nftCount.increment();

        _idToToken[_tokenId] = Token({
            nftContract: _nftContract,
            tokenId: _tokenId,
            seller: payable(msg.sender),
            owner: payable(address(this)),
            tokenURI: _tokenURI,
            name: _name,
            price: _price,
            isListed: true,
            listingTime: block.timestamp
        });

        emit NFTListed(
            _nftContract,
            _tokenId,
            msg.sender,
            address(this),
            LISTING_FEE,
             block.timestamp 
        );
    }

    /**
     * @dev Allows users to buy an NFT listed on the marketplace. The buyer must send enough ether to cover
     * the NFT's listed price. The function transfers the NFT from the current owner to the buyer and updates
     * the marketplace state accordingly.
     *
     * @param _nftContract The address of the ERC721 NFT contract.
     * @param _tokenId The unique identifier for the NFT being purchased.
     *
     * Requirements:
     * - The sent value (`msg.value`) must at least equal the NFT's listed price.
     * - The NFT must be listed for sale in the marketplace.
     *
     * The function transfers the sale amount to the seller, transfers the NFT to the buyer, updates the NFT's
     * ownership status in the marketplace, and increments the count of NFTs sold. It also emits an `NFTSold`
     * event upon successful transaction.
     */
    function buyNFT(address _nftContract, uint256 _tokenId)
        public
        payable
        nonReentrant
    {
        address owner = IERC721(_nftContract).ownerOf(_tokenId);
        Token storage nft = _idToToken[_tokenId];
        require(msg.value >= nft.price,"Not enough ether to cover asking price");

        address payable buyer = payable(msg.sender);
        payable(nft.seller).transfer(msg.value);

        IERC721(_nftContract).transferFrom(owner, msg.sender, nft.tokenId);
        IERC721(_nftContract).setApprovalForAll(msg.sender, true);

        _marketOwner.transfer(LISTING_FEE);
        nft.owner = buyer;
        nft.isListed = false;

        _nftsSold.increment();
        emit NFTSold(_nftContract, nft.tokenId, nft.seller, buyer, msg.value);
    }

    /**
     * @dev Allows an NFT owner to relist an NFT they've purchased on the marketplace.
     * Requires the relisting fee to be sent with the transaction.
     *
     * @param _nftContract Address of the NFT contract.
     * @param _tokenId ID of the NFT being relisted.
     *
     * The function transfers the NFT from the current owner back to the marketplace contract,
     * marks it as listed, and updates the seller to the current caller.
     */
    function resellNFT(address _nftContract, uint256 _tokenId)
        public
        payable
        nonReentrant
    {
        address owner = IERC721(_nftContract).ownerOf(_tokenId);
        Token storage nft = _idToToken[_tokenId];

        require(msg.value == LISTING_FEE, "Not enough ether for listing fee");

        // UPDATE
        IERC721(_nftContract).transferFrom(owner, address(this), _tokenId);

        nft.seller = payable(msg.sender);
        nft.owner = payable(address(this));
        nft.isListed = true;

        _nftsSold.decrement();
        emit NFTListed(
            _nftContract,
            _tokenId,
            msg.sender,
            address(this),
            LISTING_FEE,
            block.timestamp
        );
    }

    /**
     * @dev Returns the current listing fee for the marketplace.
     */
    function getListingFee() public view returns (uint256) {
        return LISTING_FEE;
    }

    /**
     * @dev Retrieves details for a listed NFT by its ID.
     *
     * @param _tokenId ID of the NFT to retrieve details for.
     * @return Token struct with NFT details.
     */
    function getTokenForId(uint256 _tokenId)
        public
        view
        returns (Token memory)
    {
        return _idToToken[_tokenId];
    }

    /**
     * @dev Returns the current balance of Ether held by the marketplace contract.
     */
    function getMarketPlaceBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns the total count of NFTs listed on the marketplace.
     */
    function getItemsCount() public view returns (uint256) {
        return _nftCount.current();
    }

    /**
     * @dev Returns the total number of NFTs sold through the marketplace.
     */
    function getItemsSold() public view returns (uint256) {
        return _nftsSold.current();
    }
}
