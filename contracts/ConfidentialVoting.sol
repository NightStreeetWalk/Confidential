// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.20;

import "fhevm/lib/TFHE.sol"; // Import Zama's FHEVM library

contract ConfidentialVoting {
    address public owner; // Contract owner who can decrypt results
    mapping(uint32 => euint32) private voteCounts; // Encrypted vote counts per candidate
    mapping(address => bool) private hasVoted; // Track if user has voted
    uint32 public candidateCount; // Number of candidates
    euint32 private totalVotes; // Encrypted total vote count

    constructor(uint32 _candidateCount) {
        owner = msg.sender;
        candidateCount = _candidateCount;
        totalVotes = TFHE.asEuint32(0); // Initialize encrypted total to 0
    }

    // Cast an encrypted vote for a candidate
    function castVote(bytes calldata encryptedVote, uint32 candidateId) external {
        require(!hasVoted[msg.sender], "Already voted");
        require(candidateId < candidateCount, "Invalid candidate ID");

        // Decrypt and validate vote (expects encrypted 1 for a valid vote)
        euint32 vote = TFHE.asEuint32(encryptedVote);
        require(TFHE.decrypt(TFHE.eq(vote, TFHE.asEuint32(1))), "Invalid vote");

        // Update encrypted vote count for the candidate
        voteCounts[candidateId] = TFHE.add(voteCounts[candidateId], vote);
        totalVotes = TFHE.add(totalVotes, vote);
        hasVoted[msg.sender] = true;
    }

    // Get encrypted vote count for a candidate
    function getVoteCount(uint32 candidateId) external view returns (bytes memory) {
        require(candidateId < candidateCount, "Invalid candidate ID");
        return TFHE.encrypt32(voteCounts[candidateId]);
    }

    // Decrypt total votes (only owner)
    function decryptTotalVotes() external view onlyOwner returns (uint32) {
        return TFHE.decrypt(totalVotes);
    }

    // Decrypt candidate vote count (only owner)
    function decryptVoteCount(uint32 candidateId) external view onlyOwner returns (uint32) {
        require(candidateId < candidateCount, "Invalid candidate ID");
        return TFHE.decrypt(voteCounts[candidateId]);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
