const fs = require('fs');
const { StandardMerkleTree } = require('@openzeppelin/merkle-tree');
const claimAddresses = require('./claim-addresses.json');

// Array of arrays containing merkle tree leaf constituents
// In the case of the ANFD drop, we only need the address (all addresses receive the same amount)
const claimAddressesMatrix = claimAddresses.map((address) => [address]);

// Build the merkle tree using the ANFD claim addresses
// https://github.com/OpenZeppelin/merkle-tree#building-a-tree
const tree = StandardMerkleTree.of(claimAddressesMatrix, ['address']);

// Write the merkle root to a text file which will be stored on-chain for proof verification
fs.writeFileSync(`${__dirname}/merkleRoot.txt`, tree.root);
