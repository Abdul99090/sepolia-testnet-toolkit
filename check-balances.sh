#!/usr/bin/env bash
# Print Sepolia ETH + test USDC balances for an address.
# Usage: ./check-balances.sh <address>
# Requires: Foundry `cast` on PATH.
set -euo pipefail

ADDR="${1:?usage: check-balances.sh <address>}"
RPC="${SEPOLIA_RPC:-https://ethereum-sepolia-rpc.publicnode.com}"
USDC="0xcc194e1a843B658526D0D5C431f670028582Ae17"

ETH=$(cast balance "$ADDR" --rpc-url "$RPC")
USDC_RAW=$(cast call "$USDC" "balanceOf(address)(uint256)" "$ADDR" --rpc-url "$RPC")

echo "Address : $ADDR"
echo "ETH     : $ETH wei"
echo "USDC    : $USDC_RAW micro-USDC (divide by 1e6)"
