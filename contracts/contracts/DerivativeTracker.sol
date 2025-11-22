// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DerivativeTracker
 * @dev Track derivative works and their relationships to original IP
 * @notice Maintains a graph of IP derivations and transformations
 */
contract DerivativeTracker is Ownable, ReentrancyGuard {

    // Derivative relationship types
    enum DerivativeType {
        Remix,
        Adaptation,
        Translation,
        Compilation,
        Transformation,
        Inspired
    }

    // Derivative work structure
    struct Derivative {
        bytes32 derivativeId;
        bytes32 originalId;
        address creator;
        DerivativeType derivativeType;
        string metadata; // IPFS hash
        uint256 createdAt;
        bool isVerified;
        uint256 generationLevel; // Distance from original
    }

    // IP relationship
    struct IPRelationship {
        bytes32 fromIP;
        bytes32 toIP;
        DerivativeType relationshipType;
        uint256 weight; // Influence percentage
    }

    // Mappings
    mapping(bytes32 => Derivative) public derivatives;
    mapping(bytes32 => bytes32[]) public ipDerivatives; // Original => Derivatives
    mapping(bytes32 => bytes32) public derivativeToOriginal; // Derivative => Original
    mapping(bytes32 => IPRelationship[]) public ipRelationships;
    mapping(address => bytes32[]) public creatorDerivatives;
    mapping(bytes32 => uint256) public derivativeCount;

    // Events
    event DerivativeCreated(
        bytes32 indexed derivativeId,
        bytes32 indexed originalId,
        address indexed creator,
        DerivativeType derivativeType,
        uint256 generationLevel
    );

    event DerivativeVerified(bytes32 indexed derivativeId);

    event RelationshipEstablished(
        bytes32 indexed fromIP,
        bytes32 indexed toIP,
        DerivativeType relationshipType,
        uint256 weight
    );

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Create a new derivative work
     */
    function createDerivative(
        bytes32 originalId,
        address creator,
        DerivativeType derivativeType,
        string calldata metadata
    ) external nonReentrant returns (bytes32) {
        require(creator != address(0), "Invalid creator");
        require(bytes(metadata).length > 0, "Metadata required");

        bytes32 derivativeId = keccak256(
            abi.encodePacked(
                originalId,
                creator,
                block.timestamp,
                derivativeCount[originalId]
            )
        );

        // Calculate generation level
        uint256 generationLevel = 1;
        if (derivativeToOriginal[originalId] != bytes32(0)) {
            // This is a derivative of a derivative
            Derivative memory parentDerivative = derivatives[originalId];
            generationLevel = parentDerivative.generationLevel + 1;
        }

        derivatives[derivativeId] = Derivative({
            derivativeId: derivativeId,
            originalId: originalId,
            creator: creator,
            derivativeType: derivativeType,
            metadata: metadata,
            createdAt: block.timestamp,
            isVerified: false,
            generationLevel: generationLevel
        });

        ipDerivatives[originalId].push(derivativeId);
        derivativeToOriginal[derivativeId] = originalId;
        creatorDerivatives[creator].push(derivativeId);
        derivativeCount[originalId]++;

        emit DerivativeCreated(
            derivativeId,
            originalId,
            creator,
            derivativeType,
            generationLevel
        );

        return derivativeId;
    }

    /**
     * @dev Verify a derivative work (only owner)
     */
    function verifyDerivative(bytes32 derivativeId) external onlyOwner {
        require(
            derivatives[derivativeId].derivativeId != bytes32(0),
            "Derivative not found"
        );
        require(
            !derivatives[derivativeId].isVerified,
            "Already verified"
        );

        derivatives[derivativeId].isVerified = true;

        emit DerivativeVerified(derivativeId);
    }

    /**
     * @dev Establish relationship between IP assets
     */
    function establishRelationship(
        bytes32 fromIP,
        bytes32 toIP,
        DerivativeType relationshipType,
        uint256 weight
    ) external nonReentrant {
        require(weight <= 100, "Weight must be <= 100");

        IPRelationship memory relationship = IPRelationship({
            fromIP: fromIP,
            toIP: toIP,
            relationshipType: relationshipType,
            weight: weight
        });

        ipRelationships[fromIP].push(relationship);

        emit RelationshipEstablished(
            fromIP,
            toIP,
            relationshipType,
            weight
        );
    }

    /**
     * @dev Get all derivatives of an IP
     */
    function getDerivatives(bytes32 ipId)
        external
        view
        returns (bytes32[] memory)
    {
        return ipDerivatives[ipId];
    }

    /**
     * @dev Get derivative details
     */
    function getDerivative(bytes32 derivativeId)
        external
        view
        returns (Derivative memory)
    {
        return derivatives[derivativeId];
    }

    /**
     * @dev Get original IP for a derivative
     */
    function getOriginal(bytes32 derivativeId)
        external
        view
        returns (bytes32)
    {
        return derivativeToOriginal[derivativeId];
    }

    /**
     * @dev Get all derivatives by a creator
     */
    function getCreatorDerivatives(address creator)
        external
        view
        returns (bytes32[] memory)
    {
        return creatorDerivatives[creator];
    }

    /**
     * @dev Get derivative count for an IP
     */
    function getDerivativeCount(bytes32 ipId)
        external
        view
        returns (uint256)
    {
        return derivativeCount[ipId];
    }

    /**
     * @dev Get IP relationships
     */
    function getRelationships(bytes32 ipId)
        external
        view
        returns (IPRelationship[] memory)
    {
        return ipRelationships[ipId];
    }

    /**
     * @dev Get full derivative tree
     */
    function getDerivativeTree(bytes32 rootId, uint256 maxDepth)
        external
        view
        returns (bytes32[] memory)
    {
        require(maxDepth > 0 && maxDepth <= 10, "Invalid depth");

        bytes32[] memory tree = new bytes32[](1000); // Max size
        uint256 index = 0;

        tree[index] = rootId;
        index++;

        index = _buildTree(rootId, tree, index, maxDepth, 1);

        // Resize array to actual size
        bytes32[] memory result = new bytes32[](index);
        for (uint256 i = 0; i < index; i++) {
            result[i] = tree[i];
        }

        return result;
    }

    /**
     * @dev Internal function to build derivative tree recursively
     */
    function _buildTree(
        bytes32 nodeId,
        bytes32[] memory tree,
        uint256 currentIndex,
        uint256 maxDepth,
        uint256 currentDepth
    ) private view returns (uint256) {
        if (currentDepth >= maxDepth) {
            return currentIndex;
        }

        bytes32[] memory children = ipDerivatives[nodeId];

        for (uint256 i = 0; i < children.length && currentIndex < 1000; i++) {
            tree[currentIndex] = children[i];
            currentIndex++;

            currentIndex = _buildTree(
                children[i],
                tree,
                currentIndex,
                maxDepth,
                currentDepth + 1
            );
        }

        return currentIndex;
    }

    /**
     * @dev Check if an IP is a derivative
     */
    function isDerivative(bytes32 ipId) external view returns (bool) {
        return derivativeToOriginal[ipId] != bytes32(0);
    }

    /**
     * @dev Check if derivative is verified
     */
    function isVerified(bytes32 derivativeId) external view returns (bool) {
        return derivatives[derivativeId].isVerified;
    }
}
