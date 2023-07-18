const merkleProofs = require('./merkleProofs.json');

const ADDRESS = '0x1d4B9b250B1Bd41DAA35d94BF9204Ec1b0494eE3';

// Log the merkle proof for the address
console.log(merkleProofs[ADDRESS.toLowerCase()]);
