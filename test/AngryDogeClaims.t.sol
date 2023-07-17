// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {AngryDogeClaims} from "src/AngryDogeClaims.sol";

contract AngryDogeClaimsTest is Test {
    // ANFD token contract
    ERC20 private constant ANFD =
        ERC20(0x4F14cDBd815B79E9624121f564f24685c6B1211b);

    // First address from the ANFD claims address list for testing purposes
    address private constant CLAIMER =
        0x7eAf8FC3eF869381Fb07aD7191bf31805F76CE72;

    // An account which has ANFD which we can use to fund the claims contract w/ ANFD
    address private constant ANFD_TOKEN_SOURCE =
        0x2F4D8FDF45C2971156440504aE421Ff3ac31505a;

    AngryDogeClaims private immutable claims;

    bytes32[] private claimerProof = [
        // Bytes32 type not inferred so we need to explicitly cast the values
        bytes32(
            0x1048b4b510efdf8028813af3b737cd5a79b7dc89d4705ebed8fb5937eb70fa10
        ),
        bytes32(
            0x587d8572933b30f0e1d2d379a60c71d8a291073e3a0ba496448fa82a3a724f72
        ),
        bytes32(
            0x18b87320ba55568d0e5811569104fb83df5f5c669f1429864e94f9248df2e6fa
        ),
        bytes32(
            0x1d1b613bcbb30dc5c2b2d121773a156e11659749acf3ada121b9643beb0d4e47
        ),
        bytes32(
            0xcbf6ec4d458bb9b878dade90404bc3b0861e53c7027dbf92484243a1f916165a
        ),
        bytes32(
            0xce35519c0467f50c3a9c9ffd134311aaf7e8d18f7014afcbfd4bed6f6a6691ce
        ),
        bytes32(
            0x07133204246a8d1194b122818cb9253ba5553938d9576e0e5be97e4d00e03e89
        ),
        bytes32(
            0x0ca4cc436231eb04249c3d291b4fa29c58402b0792612040fb9d3f5fbbd7dfac
        ),
        bytes32(
            0xc755f87a4c3bca153d7a796711a44a3cc70299317c41e83104873b7875e0de2f
        ),
        bytes32(
            0xd6201973cee40ca0473307b79e2e7a991e94e2f35baab64e0dac24cf94a15343
        ),
        bytes32(
            0x68b6ea2c31f7ffad37f146f6e3112faa604e411ffe4fc9dce8b673371528795b
        ),
        bytes32(
            0x3750a8e74cd3984ed51c6fa5fdbff864ee809d452eb96ba5941b469097273bfd
        ),
        bytes32(
            0x4937d80247a8254e624f741adbd4ebe38073153d6c1c7c80a9e9dcb642ef3845
        ),
        bytes32(
            0x4a10a0999061c0dc723e831f74b228e9bf7d1667e185388c26c8f3b5451a5b4e
        ),
        bytes32(
            0xd8ab0e918bd7cb838c7b1d7d6b95ed8d6c815ddcf6a9c842b92774432cc6c4a9
        ),
        bytes32(
            0xe74acaec80335fc8f0506dcab966394b334048b3e9e0f8a26036245a3f6a3039
        ),
        bytes32(
            0xc787b83498596a75a40627d146d22f0353e717d004eee209cbd957eb3f21843d
        )
    ];

    event Claim(address indexed claimer);

    constructor() {
        bytes32 merkleRoot = 0xba3bbb0c37381d1de79f9c7efbb117cda807fbf830e68fc4eacb228421cfa78b;
        address owner = address(this);

        claims = new AngryDogeClaims(merkleRoot, owner);

        assertEq(merkleRoot, claims.merkleRoot());
        assertEq(owner, claims.owner());

        // Impersonate the ANFD token source and transfer ANFD balance to the claims contract
        uint256 transferAmount = ANFD.balanceOf(ANFD_TOKEN_SOURCE);

        vm.prank(ANFD_TOKEN_SOURCE);

        ANFD.transfer(address(claims), transferAmount);
    }

    /*//////////////////////////////////////////////////////////////
                             claim
    //////////////////////////////////////////////////////////////*/

    function testCannotClaimEmptyProof() external {
        bytes32[] memory proof = new bytes32[](0);

        vm.prank(CLAIMER);
        vm.expectRevert(AngryDogeClaims.EmptyProof.selector);

        claims.claim(proof);
    }

    function testCannotClaimAlreadyClaimed() external {
        vm.startPrank(CLAIMER);

        claims.claim(claimerProof);

        vm.expectRevert(AngryDogeClaims.AlreadyClaimed.selector);

        claims.claim(claimerProof);

        vm.stopPrank();
    }

    function testCannotClaimInvalidProof(uint8 proofIndex) external {
        vm.assume(proofIndex < claimerProof.length);

        // Invalidate the proof
        claimerProof[proofIndex] = bytes32(0);

        vm.prank(CLAIMER);

        vm.expectRevert(AngryDogeClaims.InvalidProof.selector);

        claims.claim(claimerProof);
    }

    function testCannotClaimInvalidProofNotClaimer() external {
        // Call `claim` with a valid proof but not as the claimer
        vm.prank(address(1));

        vm.expectRevert(AngryDogeClaims.InvalidProof.selector);

        claims.claim(claimerProof);
    }

    function testClaim() external {
        uint256 claimAmount = claims.ANFD_CLAIM_AMOUNT();

        // Cache balances for verifying correct amounts were transferred when claiming
        uint256 contractBalanceBeforeClaim = ANFD.balanceOf(address(claims));
        uint256 claimerBalanceBeforeClaim = ANFD.balanceOf(CLAIMER);

        // Impersonate the claimer and claim
        vm.prank(CLAIMER);
        vm.expectEmit(true, false, false, true, address(claims));

        emit Claim(CLAIMER);

        claims.claim(claimerProof);

        // Verify that the contract ANFD balance decreased by the claim amount
        assertEq(
            contractBalanceBeforeClaim - claimAmount,
            ANFD.balanceOf(address(claims))
        );

        // Verify that the claimer ANFD balance increased by the claim amount
        assertEq(
            claimerBalanceBeforeClaim + claimAmount,
            ANFD.balanceOf(CLAIMER)
        );
    }
}
