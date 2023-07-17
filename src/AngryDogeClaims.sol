// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {MerkleProofLib} from "solmate/utils/MerkleProofLib.sol";

/**
 * @title  ANFD claims
 * @author kphed (GitHub) / ppmoon69 (Twitter)
 */
contract AngryDogeClaims is Owned {
    using SafeTransferLib for ERC20;

    // ANFD token contract
    // https://etherscan.io/address/0x4f14cdbd815b79e9624121f564f24685c6b1211b
    ERC20 public constant ANFD =
        ERC20(0x4F14cDBd815B79E9624121f564f24685c6B1211b);

    // ANFD token claim amount (120k tokens per claim - ANFD has 18 decimals)
    uint256 public constant ANFD_CLAIM_AMOUNT = 120_000e18;

    // Merkle tree root for verifying claim eligibility
    bytes32 public immutable merkleRoot;

    // Mapping of claimer addresses and their claim status
    mapping(address => bool) public claimed;

    event Claim(address indexed claimer);

    error EmptyMerkleRoot();
    error InvalidOwnerAddress();
    error EmptyProof();
    error InvalidProof();
    error AlreadyClaimed();

    constructor(bytes32 _merkleRoot, address _owner) Owned(_owner) {
        if (_merkleRoot == bytes32(0)) revert EmptyMerkleRoot();
        if (_owner == address(0)) revert InvalidOwnerAddress();

        merkleRoot = _merkleRoot;
    }

    /**
     * @notice Claim ANFD tokens
     * @param  proof  bytes32[]  Merkle proof
     */
    function claim(bytes32[] calldata proof) external {
        // Revert if proof is empty
        if (proof.length == 0) revert EmptyProof();

        // Revert if the claimer has already claimed
        if (claimed[msg.sender]) revert AlreadyClaimed();

        // Revert if the proof is invalid or if msg.sender is ineligible
        if (
            // Verify the claimer's proof against the merkle root
            !MerkleProofLib.verify(
                proof,
                merkleRoot,
                // Compute the leaf using constituent data (i.e. msg.sender/claimer address)
                // https://github.com/OpenZeppelin/merkle-tree#validating-a-proof-in-solidity
                keccak256(bytes.concat(keccak256(abi.encode(msg.sender))))
            )
        ) revert InvalidProof();

        // Set claimer's claim status to true to prevent double claiming
        claimed[msg.sender] = true;

        // Transfer ANFD tokens to the claimer (last to avoid reentrancy)
        ANFD.safeTransfer(msg.sender, ANFD_CLAIM_AMOUNT);

        emit Claim(msg.sender);
    }
}
