// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title YAMORegistry
 * @dev Registry for anchoring YAMO blocks and reasoning traces on-chain.
 */
contract YAMORegistry is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant AGENT_ROLE = keccak256("AGENT_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    struct YAMOBlock {
        string blockId;
        string previousBlock;
        address agentAddress;
        bytes32 contentHash; // Hash of the YAMO content (stored off-chain e.g. IPFS)
        uint256 timestamp;
        string consensusType;
        string ledger;
    }

    // Mapping from blockId to YAMOBlock
    mapping(string => YAMOBlock) public blocks;
    
    // Mapping to check if a blockId has been used
    mapping(string => bool) public blockExists;

    event YAMOBlockSubmitted(string indexed blockId, string previousBlock, address indexed agent, bytes32 contentHash);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) initializer public {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(AGENT_ROLE, defaultAdmin);
        _grantRole(UPGRADER_ROLE, defaultAdmin);
    }

    /**
     * @dev Submits a new YAMO block to the registry.
     * @param blockId Unique identifier for the block.
     * @param previousBlock Identifier of the previous block in the chain.
     * @param contentHash Hash of the YAMO content.
     * @param consensusType Type of consensus used.
     * @param ledger The ledger name.
     */
    function submitBlock(
        string memory blockId,
        string memory previousBlock,
        bytes32 contentHash,
        string memory consensusType,
        string memory ledger
    ) public onlyRole(AGENT_ROLE) {
        require(!blockExists[blockId], "Block already exists");
        
        blocks[blockId] = YAMOBlock({
            blockId: blockId,
            previousBlock: previousBlock,
            agentAddress: msg.sender,
            contentHash: contentHash,
            timestamp: block.timestamp,
            consensusType: consensusType,
            ledger: ledger
        });

        blockExists[blockId] = true;

        emit YAMOBlockSubmitted(blockId, previousBlock, msg.sender, contentHash);
    }

    /**
     * @dev Verifies a block's content hash.
     * @param blockId The block identifier.
     * @param contentHash The hash to verify against the stored hash.
     */
    function verifyBlock(string memory blockId, bytes32 contentHash) public view returns (bool) {
        require(blockExists[blockId], "Block does not exist");
        return blocks[blockId].contentHash == contentHash;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
