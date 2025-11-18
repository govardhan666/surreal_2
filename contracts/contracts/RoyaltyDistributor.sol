// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title RoyaltyDistributor
 * @dev Automated royalty distribution system for IP assets and their derivatives
 * @notice Handles multi-level royalty splits across derivative work chains
 */
contract RoyaltyDistributor is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _distributionIds;

    // Royalty split structure
    struct RoyaltySplit {
        address recipient;
        uint256 percentage; // In basis points (100 = 1%)
    }

    // Distribution record
    struct Distribution {
        uint256 distributionId;
        address ipAsset;
        uint256 tokenId;
        uint256 totalAmount;
        uint256 timestamp;
        bool isProcessed;
    }

    // IP Asset royalty configuration
    struct IPRoyaltyConfig {
        address[] recipients;
        uint256[] percentages;
        uint256 totalPercentage;
        bool isConfigured;
    }

    // Derivative work tracking
    struct DerivativeWork {
        address originalIP;
        uint256 originalTokenId;
        address derivativeIP;
        uint256 derivativeTokenId;
        uint256 derivativeLevel; // 1 for direct, 2+ for derivatives of derivatives
        uint256 royaltyPercentage;
        bool isActive;
    }

    // Constants
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MAX_RECIPIENTS = 20;
    uint256 public constant MAX_ROYALTY_PERCENTAGE = 5000; // 50% max

    // Mappings
    mapping(bytes32 => IPRoyaltyConfig) public ipRoyaltyConfigs;
    mapping(bytes32 => DerivativeWork[]) public derivativeWorks;
    mapping(uint256 => Distribution) public distributions;
    mapping(address => uint256) public pendingWithdrawals;
    mapping(bytes32 => uint256) public totalRoyaltiesEarned;

    // Events
    event RoyaltyConfigured(
        address indexed ipAsset,
        uint256 indexed tokenId,
        address[] recipients,
        uint256[] percentages
    );

    event DerivativeRegistered(
        address indexed originalIP,
        uint256 originalTokenId,
        address indexed derivativeIP,
        uint256 derivativeTokenId,
        uint256 royaltyPercentage
    );

    event RoyaltyDistributed(
        uint256 indexed distributionId,
        address indexed ipAsset,
        uint256 tokenId,
        uint256 totalAmount,
        uint256 recipientCount
    );

    event RoyaltyWithdrawn(
        address indexed recipient,
        uint256 amount
    );

    event DerivativeDeactivated(
        address indexed derivativeIP,
        uint256 derivativeTokenId
    );

    constructor() {}

    /**
     * @dev Configure royalty splits for an IP asset
     */
    function configureRoyalty(
        address ipAsset,
        uint256 tokenId,
        address[] calldata recipients,
        uint256[] calldata percentages
    ) external nonReentrant {
        require(recipients.length > 0, "No recipients specified");
        require(
            recipients.length == percentages.length,
            "Arrays length mismatch"
        );
        require(
            recipients.length <= MAX_RECIPIENTS,
            "Too many recipients"
        );

        bytes32 ipHash = keccak256(abi.encodePacked(ipAsset, tokenId));

        // Calculate total percentage
        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < percentages.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient");
            require(percentages[i] > 0, "Invalid percentage");
            totalPercentage += percentages[i];
        }

        require(
            totalPercentage == BASIS_POINTS,
            "Percentages must sum to 100%"
        );

        ipRoyaltyConfigs[ipHash] = IPRoyaltyConfig({
            recipients: recipients,
            percentages: percentages,
            totalPercentage: totalPercentage,
            isConfigured: true
        });

        emit RoyaltyConfigured(ipAsset, tokenId, recipients, percentages);
    }

    /**
     * @dev Register a derivative work
     */
    function registerDerivative(
        address originalIP,
        uint256 originalTokenId,
        address derivativeIP,
        uint256 derivativeTokenId,
        uint256 royaltyPercentage
    ) external nonReentrant {
        require(
            royaltyPercentage <= MAX_ROYALTY_PERCENTAGE,
            "Royalty too high"
        );

        bytes32 originalHash = keccak256(
            abi.encodePacked(originalIP, originalTokenId)
        );
        bytes32 derivativeHash = keccak256(
            abi.encodePacked(derivativeIP, derivativeTokenId)
        );

        // Calculate derivative level
        uint256 level = 1;
        DerivativeWork[] memory existingDerivatives = derivativeWorks[
            originalHash
        ];

        for (uint256 i = 0; i < existingDerivatives.length; i++) {
            if (
                existingDerivatives[i].derivativeIP == derivativeIP &&
                existingDerivatives[i].derivativeTokenId == derivativeTokenId
            ) {
                level = existingDerivatives[i].derivativeLevel + 1;
                break;
            }
        }

        DerivativeWork memory derivative = DerivativeWork({
            originalIP: originalIP,
            originalTokenId: originalTokenId,
            derivativeIP: derivativeIP,
            derivativeTokenId: derivativeTokenId,
            derivativeLevel: level,
            royaltyPercentage: royaltyPercentage,
            isActive: true
        });

        derivativeWorks[originalHash].push(derivative);
        derivativeWorks[derivativeHash].push(derivative);

        emit DerivativeRegistered(
            originalIP,
            originalTokenId,
            derivativeIP,
            derivativeTokenId,
            royaltyPercentage
        );
    }

    /**
     * @dev Distribute royalties for an IP asset
     */
    function distributeRoyalties(
        address ipAsset,
        uint256 tokenId
    ) external payable nonReentrant {
        require(msg.value > 0, "No royalty amount provided");

        bytes32 ipHash = keccak256(abi.encodePacked(ipAsset, tokenId));
        IPRoyaltyConfig memory config = ipRoyaltyConfigs[ipHash];

        require(config.isConfigured, "Royalty not configured");

        _distributionIds.increment();
        uint256 distributionId = _distributionIds.current();

        // Record distribution
        distributions[distributionId] = Distribution({
            distributionId: distributionId,
            ipAsset: ipAsset,
            tokenId: tokenId,
            totalAmount: msg.value,
            timestamp: block.timestamp,
            isProcessed: false
        });

        // Distribute to recipients
        uint256 totalDistributed = 0;
        for (uint256 i = 0; i < config.recipients.length; i++) {
            uint256 amount = (msg.value * config.percentages[i]) / BASIS_POINTS;
            pendingWithdrawals[config.recipients[i]] += amount;
            totalDistributed += amount;
        }

        // Handle any rounding dust
        if (totalDistributed < msg.value) {
            pendingWithdrawals[config.recipients[0]] += (msg.value - totalDistributed);
        }

        distributions[distributionId].isProcessed = true;
        totalRoyaltiesEarned[ipHash] += msg.value;

        emit RoyaltyDistributed(
            distributionId,
            ipAsset,
            tokenId,
            msg.value,
            config.recipients.length
        );
    }

    /**
     * @dev Distribute royalties with derivative tracking
     */
    function distributeWithDerivatives(
        address ipAsset,
        uint256 tokenId
    ) external payable nonReentrant {
        require(msg.value > 0, "No royalty amount provided");

        bytes32 ipHash = keccak256(abi.encodePacked(ipAsset, tokenId));

        // Get all derivatives for this IP
        DerivativeWork[] memory derivatives = derivativeWorks[ipHash];

        uint256 remainingAmount = msg.value;

        // First, distribute to derivative parents (if this is a derivative)
        for (uint256 i = 0; i < derivatives.length; i++) {
            if (
                derivatives[i].derivativeIP == ipAsset &&
                derivatives[i].derivativeTokenId == tokenId &&
                derivatives[i].isActive
            ) {
                // This IP is a derivative, pay royalty to original
                uint256 derivativeRoyalty = (msg.value * derivatives[i].royaltyPercentage) / BASIS_POINTS;

                bytes32 originalHash = keccak256(
                    abi.encodePacked(
                        derivatives[i].originalIP,
                        derivatives[i].originalTokenId
                    )
                );

                IPRoyaltyConfig memory originalConfig = ipRoyaltyConfigs[originalHash];

                if (originalConfig.isConfigured) {
                    // Distribute to original IP holders
                    for (uint256 j = 0; j < originalConfig.recipients.length; j++) {
                        uint256 amount = (derivativeRoyalty * originalConfig.percentages[j]) / BASIS_POINTS;
                        pendingWithdrawals[originalConfig.recipients[j]] += amount;
                        remainingAmount -= amount;
                    }
                }
            }
        }

        // Then distribute remaining to this IP's recipients
        IPRoyaltyConfig memory config = ipRoyaltyConfigs[ipHash];

        if (config.isConfigured && remainingAmount > 0) {
            for (uint256 i = 0; i < config.recipients.length; i++) {
                uint256 amount = (remainingAmount * config.percentages[i]) / BASIS_POINTS;
                pendingWithdrawals[config.recipients[i]] += amount;
            }
        }

        _distributionIds.increment();
        uint256 distributionId = _distributionIds.current();

        distributions[distributionId] = Distribution({
            distributionId: distributionId,
            ipAsset: ipAsset,
            tokenId: tokenId,
            totalAmount: msg.value,
            timestamp: block.timestamp,
            isProcessed: true
        });

        totalRoyaltiesEarned[ipHash] += msg.value;

        emit RoyaltyDistributed(
            distributionId,
            ipAsset,
            tokenId,
            msg.value,
            config.recipients.length
        );
    }

    /**
     * @dev Withdraw pending royalties
     */
    function withdraw() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawals");

        pendingWithdrawals[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit RoyaltyWithdrawn(msg.sender, amount);
    }

    /**
     * @dev Deactivate a derivative work
     */
    function deactivateDerivative(
        address derivativeIP,
        uint256 derivativeTokenId
    ) external onlyOwner {
        bytes32 derivativeHash = keccak256(
            abi.encodePacked(derivativeIP, derivativeTokenId)
        );

        DerivativeWork[] storage derivatives = derivativeWorks[derivativeHash];

        for (uint256 i = 0; i < derivatives.length; i++) {
            if (
                derivatives[i].derivativeIP == derivativeIP &&
                derivatives[i].derivativeTokenId == derivativeTokenId
            ) {
                derivatives[i].isActive = false;
            }
        }

        emit DerivativeDeactivated(derivativeIP, derivativeTokenId);
    }

    /**
     * @dev Get royalty configuration for an IP asset
     */
    function getRoyaltyConfig(address ipAsset, uint256 tokenId)
        external
        view
        returns (IPRoyaltyConfig memory)
    {
        bytes32 ipHash = keccak256(abi.encodePacked(ipAsset, tokenId));
        return ipRoyaltyConfigs[ipHash];
    }

    /**
     * @dev Get derivatives for an IP asset
     */
    function getDerivatives(address ipAsset, uint256 tokenId)
        external
        view
        returns (DerivativeWork[] memory)
    {
        bytes32 ipHash = keccak256(abi.encodePacked(ipAsset, tokenId));
        return derivativeWorks[ipHash];
    }

    /**
     * @dev Get pending withdrawal amount for an address
     */
    function getPendingWithdrawal(address account)
        external
        view
        returns (uint256)
    {
        return pendingWithdrawals[account];
    }

    /**
     * @dev Get total royalties earned by an IP asset
     */
    function getTotalRoyalties(address ipAsset, uint256 tokenId)
        external
        view
        returns (uint256)
    {
        bytes32 ipHash = keccak256(abi.encodePacked(ipAsset, tokenId));
        return totalRoyaltiesEarned[ipHash];
    }

    /**
     * @dev Get distribution details
     */
    function getDistribution(uint256 distributionId)
        external
        view
        returns (Distribution memory)
    {
        return distributions[distributionId];
    }

    /**
     * @dev Get total distributions count
     */
    function getTotalDistributions() external view returns (uint256) {
        return _distributionIds.current();
    }

    // Receive function to accept ETH
    receive() external payable {}
}
