const fs = require('fs');
const { StandardMerkleTree } = require('@openzeppelin/merkle-tree');
const claimAddresses = require('./claim-addresses.json');
const proofs = require('./merkleProofs.json');

console.log(proofs['0x7eAf8FC3eF869381Fb07aD7191bf31805F76CE72'.toLowerCase()]);

// // Array of arrays containing merkle tree leaf constituents
// // In the case of the ANFD drop, we only need the address (all addresses receive the same amount)
// const claimAddressesMatrix = claimAddresses.map((address) => [address]);

// // Build the merkle tree using the ANFD claim addresses
// // https://github.com/OpenZeppelin/merkle-tree#building-a-tree
// const tree = StandardMerkleTree.of(claimAddressesMatrix, ['address']);

// // Proofs keyed by addresses for easy look-up on the frontend
// const merkleProofsByAddress = {};

// // Iterate over entries and retrieve proofs for each one
// for (const [index, value] of tree.entries()) {
//   const [address] = value;

//   // Set proofs keyed by addresses for easy look-up by the connected user's account (frontend)
//   merkleProofsByAddress[address] = tree.getProof(index);
// }

// // Write the merkle root to a text file which will be stored on-chain for proof verification
// fs.writeFileSync(`${__dirname}/merkleRoot.txt`, tree.root);

// // Write the merkle proofs to a JSON file which will be utilized on the frontend
// fs.writeFileSync(
//   `${__dirname}/merkleProofs.json`,
//   JSON.stringify(merkleProofsByAddress)
// );
