// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./YAMORegistry.sol";

/**
 * @title YAMORegistryV2
 * @dev Extension of YAMORegistry to support IPFS content addressing.
 */
contract YAMORegistryV2 is YAMORegistry {
    // New storage variable must be appended to avoid collisions
    mapping(string => string) public blockCIDs;

    event YAMOBlockSubmittedV2(string indexed blockId, bytes32 contentHash, string ipfsCID);

    /**
     * @dev Submits a new YAMO block with IPFS CID support.
     */
    function submitBlockV2(
        string memory blockId,
        string memory previousBlock,
        bytes32 contentHash,
        string memory consensusType,
        string memory ledger,
        string memory ipfsCID
    ) public onlyRole(AGENT_ROLE) {
        // Reuse original logic for basic fields
        // We cannot call submitBlock directly if we want to avoid double-emitting events or checks,
        // but we can copy the logic or refactor. Since strict duplication is safer here:
        
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
        blockCIDs[blockId] = ipfsCID;

        // Update latest block hash for chain continuation
        latestBlockHash = contentHash;

        emit YAMOBlockSubmitted(blockId, previousBlock, msg.sender, contentHash);
        emit YAMOBlockSubmittedV2(blockId, contentHash, ipfsCID);
    }
}
