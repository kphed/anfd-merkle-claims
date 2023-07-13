# Angry Doge (ANFD) Merkle Tree-based Claims

Software versions:
- Node  v18.16.0
- NPM   v9.5.1
- Forge v0.2.0

---

To generate the merkle tree root and proofs:
1. Run `npm i` to install dependencies
2. Run `node merkle-tree/index.js`

The root will be written to merkle-tree/merkleRoot.txt, and the proofs written to merkle-tree/merkleProofs.json.

---

To test the claim contract:
1. Run `forge i` to install dependencies
2. Run `forge test --rpc-url <ETHEREUM_MAINNET_RPC_URL> -vvv`
