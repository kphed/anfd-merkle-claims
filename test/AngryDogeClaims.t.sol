// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {AngryDogeClaims} from "src/AngryDogeClaims.sol";

contract AngryDogeClaimsTest is Test {
    // ANFD token contract
    ERC20 private constant ANFD =
        ERC20(0x4F14cDBd815B79E9624121f564f24685c6B1211b);

    // Randomly-selected address from the ANFD claims address list for testing purposes
    address private constant CLAIMER =
        0x0000000000007F150Bd6f54c40A34d7C3d5e9f56;

    // An account which has ANFD which we can use to fund the claims contract w/ ANFD
    address private constant ANFD_TOKEN_SOURCE =
        0x2F4D8FDF45C2971156440504aE421Ff3ac31505a;

    AngryDogeClaims private immutable claims;

    bytes32[] private claimerProof = [
        // Bytes32 type not inferred so we need to explicitly cast the values
        bytes32(
            0x563af0d9d7ad292d314728bbe4b8a9a4a70b940cea2616786655c438754c6e93
        ),
        bytes32(
            0xe73731697ca1635721f3a8c3d1197aea99481b3dac9318c91a33b7859a9a5817
        ),
        bytes32(
            0x9c99e880aae3c8b3063241ea2533120c6e4dc12cd17227f8d0fe777554cbc5e4
        ),
        bytes32(
            0x2d73adc098d6899834eb0e4040e078f7a04043c16b6eff9e220d12d63331087a
        ),
        bytes32(
            0xc0d08485b4c531d76928dc65bc4c90491b78e77ef5ff0123230a9c7b9b14ab5b
        ),
        bytes32(
            0x1930601397cfd92122a33e1e369b4a747d3a5b68f8fc80d53e3355cf8006f687
        ),
        bytes32(
            0xe978ac5508871b198dc3b61f0ae544e34ea19cf4582e8b8790fecc1b4d013d24
        ),
        bytes32(
            0x11c3cc76c99055e05a50665f2d92cba889d4936ca95722b96586e884f684d719
        ),
        bytes32(
            0xf0ee50f6a3439170a6dc1149cf9aa07c6f505860f13a24aa347cf2b747454fcc
        ),
        bytes32(
            0xd3a1a8a2efea851b8b0c84e837ce2eb690f7d34515da9349e4d6d50afd6ab388
        ),
        bytes32(
            0x22a381cf5de594b2823e262db625b2789737d9c20f10b2709c3a958d5146cca2
        ),
        bytes32(
            0x62a404eac1b991c0d0c8978e10623aea67454f7d9ce43a2983f0610f166adf16
        ),
        bytes32(
            0xb737b97a7389096b4086c38e25beddb2ba11333eda824854ecfcd6292cdd2421
        ),
        bytes32(
            0xc242bfeb976725e140da8d5ca5703829d7ce30059ae59dc1c64ce92d36826b74
        ),
        bytes32(
            0x5bf234dc42fbb700eaf7687248b0d1e530d805bd6006bf4c031b6e1923305596
        )
    ];

    event Claim(address indexed claimer);

    constructor() {
        claims = new AngryDogeClaims(
            0x5254cfacfc11c5c033fb3c8f4f95e681f317bc33827c905459a1e2447e449323
        );

        // Impersonate the ANFD token source and transfer ANFD balance to the claims contract
        uint256 transferAmount = ANFD.balanceOf(ANFD_TOKEN_SOURCE);

        vm.prank(ANFD_TOKEN_SOURCE);

        ANFD.transfer(address(claims), transferAmount);
    }

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
