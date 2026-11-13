#!/usr/bin/env bash
# Mint Sepolia test USDC (permissionless mint on the test token).
# Usage: SEPOLIA_PRIVATE_KEY=0x... ./mint-test-usdc.sh <to-address> <amount-usdc>
# Requires: Foundry `cast` on PATH.
set -euo pipefail

TO="${1:?usage: mint-test-usdc.sh <to-address> <amount-usdc>}"
AMOUNT_HUMAN="${2:?usage: mint-test-usdc.sh <to-address> <amount-usdc>}"
RPC="${SEPOLIA_RPC:-https://ethereum-sepolia-rpc.publicnode.com}"
USDC="0xcc194e1a843B658526D0D5C431f670028582Ae17"

: "${SEPOLIA_PRIVATE_KEY:?set SEPOLIA_PRIVATE_KEY in the environment}"

# USDC has 6 decimals: convert whole-USDC amount to micro units (integer math only).
AMOUNT_MICRO=$(( AMOUNT_HUMAN * 1000000 ))

echo "Minting ${AMOUNT_HUMAN} test USDC (${AMOUNT_MICRO} micro) to ${TO} ..."
cast send "$USDC" "mint(address,uint256)" "$TO" "$AMOUNT_MICRO" \
  --rpc-url "$RPC" --private-key "$SEPOLIA_PRIVATE_KEY"

echo "New balance (micro-USDC):"
cast call "$USDC" "balanceOf(address)(uint256)" "$TO" --rpc-url "$RPC"
