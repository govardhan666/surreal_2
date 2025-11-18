// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title IPMarketplace
 * @dev Decentralized marketplace for trading and licensing IP assets
 * @notice Integrates with Story Protocol for programmable IP licensing
 */
contract IPMarketplace is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    // Listing counter
    Counters.Counter private _listingIds;
    Counters.Counter private _licenseIds;

    // Marketplace fee (in basis points, 250 = 2.5%)
    uint256 public platformFee = 250;
    uint256 public constant FEE_DENOMINATOR = 10000;

    // Listing types
    enum ListingType { Sale, License }
    enum ListingStatus { Active, Sold, Cancelled }
    enum LicenseType { Commercial, NonCommercial, Derivative }

    // Listing structure
    struct Listing {
        uint256 listingId;
        address seller;
        address ipAsset;
        uint256 tokenId;
        uint256 price;
        ListingType listingType;
        ListingStatus status;
        uint256 createdAt;
        uint256 expiresAt;
    }

    // License structure
    struct License {
        uint256 licenseId;
        uint256 listingId;
        address licensor;
        address licensee;
        LicenseType licenseType;
        uint256 price;
        uint256 royaltyPercentage;
        uint256 duration;
        uint256 issuedAt;
        uint256 expiresAt;
        bool isActive;
    }

    // Mappings
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => License) public licenses;
    mapping(address => uint256[]) public userListings;
    mapping(address => uint256[]) public userLicenses;
    mapping(bytes32 => bool) public isIPListed;

    // Events
    event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        address indexed ipAsset,
        uint256 tokenId,
        uint256 price,
        ListingType listingType
    );

    event ListingSold(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 price
    );

    event ListingCancelled(uint256 indexed listingId);

    event LicenseIssued(
        uint256 indexed licenseId,
        uint256 indexed listingId,
        address indexed licensee,
        LicenseType licenseType,
        uint256 price,
        uint256 duration
    );

    event PlatformFeeUpdated(uint256 newFee);

    event FundsWithdrawn(address indexed recipient, uint256 amount);

    constructor() {}

    /**
     * @dev Create a new listing for an IP asset
     */
    function createListing(
        address ipAsset,
        uint256 tokenId,
        uint256 price,
        ListingType listingType,
        uint256 duration
    ) external nonReentrant returns (uint256) {
        require(price > 0, "Price must be greater than 0");
        require(duration > 0, "Duration must be greater than 0");
        require(
            IERC721(ipAsset).ownerOf(tokenId) == msg.sender,
            "Not the owner of IP asset"
        );

        bytes32 ipHash = keccak256(abi.encodePacked(ipAsset, tokenId));
        require(!isIPListed[ipHash], "IP already listed");

        _listingIds.increment();
        uint256 listingId = _listingIds.current();

        listings[listingId] = Listing({
            listingId: listingId,
            seller: msg.sender,
            ipAsset: ipAsset,
            tokenId: tokenId,
            price: price,
            listingType: listingType,
            status: ListingStatus.Active,
            createdAt: block.timestamp,
            expiresAt: block.timestamp + duration
        });

        userListings[msg.sender].push(listingId);
        isIPListed[ipHash] = true;

        emit ListingCreated(
            listingId,
            msg.sender,
            ipAsset,
            tokenId,
            price,
            listingType
        );

        return listingId;
    }

    /**
     * @dev Buy an IP asset from the marketplace
     */
    function buyIPAsset(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];

        require(listing.status == ListingStatus.Active, "Listing not active");
        require(
            listing.listingType == ListingType.Sale,
            "Not a sale listing"
        );
        require(block.timestamp <= listing.expiresAt, "Listing expired");
        require(msg.value >= listing.price, "Insufficient payment");
        require(msg.sender != listing.seller, "Cannot buy your own listing");

        // Calculate fees
        uint256 fee = (listing.price * platformFee) / FEE_DENOMINATOR;
        uint256 sellerProceeds = listing.price - fee;

        // Update listing status
        listing.status = ListingStatus.Sold;
        bytes32 ipHash = keccak256(
            abi.encodePacked(listing.ipAsset, listing.tokenId)
        );
        isIPListed[ipHash] = false;

        // Transfer IP asset
        IERC721(listing.ipAsset).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        // Transfer funds
        payable(listing.seller).transfer(sellerProceeds);

        // Refund excess payment
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }

        emit ListingSold(listingId, msg.sender, listing.price);
    }

    /**
     * @dev Purchase a license for an IP asset
     */
    function purchaseLicense(
        uint256 listingId,
        LicenseType licenseType,
        uint256 duration
    ) external payable nonReentrant returns (uint256) {
        Listing storage listing = listings[listingId];

        require(listing.status == ListingStatus.Active, "Listing not active");
        require(
            listing.listingType == ListingType.License,
            "Not a license listing"
        );
        require(block.timestamp <= listing.expiresAt, "Listing expired");
        require(msg.value >= listing.price, "Insufficient payment");

        // Calculate royalty percentage based on license type
        uint256 royaltyPercentage = _calculateRoyalty(licenseType);

        _licenseIds.increment();
        uint256 licenseId = _licenseIds.current();

        licenses[licenseId] = License({
            licenseId: licenseId,
            listingId: listingId,
            licensor: listing.seller,
            licensee: msg.sender,
            licenseType: licenseType,
            price: listing.price,
            royaltyPercentage: royaltyPercentage,
            duration: duration,
            issuedAt: block.timestamp,
            expiresAt: block.timestamp + duration,
            isActive: true
        });

        userLicenses[msg.sender].push(licenseId);

        // Calculate and transfer fees
        uint256 fee = (listing.price * platformFee) / FEE_DENOMINATOR;
        uint256 licensorProceeds = listing.price - fee;

        payable(listing.seller).transfer(licensorProceeds);

        // Refund excess payment
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }

        emit LicenseIssued(
            licenseId,
            listingId,
            msg.sender,
            licenseType,
            listing.price,
            duration
        );

        return licenseId;
    }

    /**
     * @dev Cancel a listing
     */
    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];

        require(listing.seller == msg.sender, "Not the seller");
        require(listing.status == ListingStatus.Active, "Listing not active");

        listing.status = ListingStatus.Cancelled;
        bytes32 ipHash = keccak256(
            abi.encodePacked(listing.ipAsset, listing.tokenId)
        );
        isIPListed[ipHash] = false;

        emit ListingCancelled(listingId);
    }

    /**
     * @dev Check if a license is valid
     */
    function isLicenseValid(uint256 licenseId) external view returns (bool) {
        License memory license = licenses[licenseId];
        return
            license.isActive && block.timestamp <= license.expiresAt;
    }

    /**
     * @dev Get user's active listings
     */
    function getUserListings(address user)
        external
        view
        returns (uint256[] memory)
    {
        return userListings[user];
    }

    /**
     * @dev Get user's licenses
     */
    function getUserLicenses(address user)
        external
        view
        returns (uint256[] memory)
    {
        return userLicenses[user];
    }

    /**
     * @dev Update platform fee (only owner)
     */
    function updatePlatformFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Fee too high"); // Max 10%
        platformFee = newFee;
        emit PlatformFeeUpdated(newFee);
    }

    /**
     * @dev Withdraw accumulated fees (only owner)
     */
    function withdrawFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner()).transfer(balance);
        emit FundsWithdrawn(owner(), balance);
    }

    /**
     * @dev Calculate royalty percentage based on license type
     */
    function _calculateRoyalty(LicenseType licenseType)
        private
        pure
        returns (uint256)
    {
        if (licenseType == LicenseType.NonCommercial) {
            return 0;
        } else if (licenseType == LicenseType.Commercial) {
            return 500; // 5%
        } else {
            return 1000; // 10% for derivative works
        }
    }

    /**
     * @dev Get listing details
     */
    function getListing(uint256 listingId)
        external
        view
        returns (Listing memory)
    {
        return listings[listingId];
    }

    /**
     * @dev Get license details
     */
    function getLicense(uint256 licenseId)
        external
        view
        returns (License memory)
    {
        return licenses[licenseId];
    }

    /**
     * @dev Get active listings count
     */
    function getActiveListingsCount() external view returns (uint256) {
        return _listingIds.current();
    }

    /**
     * @dev Get total licenses issued
     */
    function getTotalLicensesIssued() external view returns (uint256) {
        return _licenseIds.current();
    }

    // Required for receiving NFTs
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
