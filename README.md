# Sepolia Testnet Toolkit

Practical notes and tiny scripts for funding a wallet on **Ethereum Sepolia** —
written from real usage while building and testing agents on testnet
(November 2026). Everything here was actually used; timings and failure modes
are noted honestly so you don't repeat the dead ends.

## 1. Get Sepolia ETH (for gas)

| Route | Result | Notes |
|---|---|---|
| **Google Cloud Web3 faucet** | ✅ 0.05 ETH, fast | The reliable one. Requires a Google sign-in. |
| PoW faucets (browser-mined) | ⚠️ Too slow in practice | Proof-of-work faucets can take extremely long in a headless/automated browser. Fine by hand, painful in automation. |
| Email-verification faucets | ⚠️ Hit or miss | If the verification email never arrives, the account is stuck at "verify your email first" and there is no recovery path. Don't loop retries — switch routes. |

Rule of thumb: **0.05 Sepolia ETH is plenty** for a full day of contract
deploys + dozens of transactions (typical simple calls cost ~0.0001–0.001 ETH).

## 2. Get test USDC without a faucet

The Sepolia test USDC token below exposes a **permissionless `mint`** — anyone
can mint test USDC to any address. No faucet queue, no daily cap dance.

- Token: `0xcc194e1a843B658526D0D5C431f670028582Ae17` (Sepolia, 6 decimals)
- Function: `mint(address to, uint256 amount)` — selector `0x40c10f19`
- Amounts are in micro-units: `1000000` = 1.00 USDC.

Mint exactly what you need (it's testnet money — be a good citizen).

### With Foundry `cast`

```bash
RPC=https://ethereum-sepolia-rpc.publicnode.com
USDC=0xcc194e1a843B658526D0D5C431f670028582Ae17

cast send $USDC "mint(address,uint256)" $YOUR_ADDRESS 1000000 \
  --rpc-url $RPC --private-key $YOUR_PRIVATE_KEY
```

Or use the included script: `./mint-test-usdc.sh <address> <amount-usdc>`

### Verify the balance

```bash
cast call $USDC "balanceOf(address)(uint256)" $YOUR_ADDRESS --rpc-url $RPC
# raw value is micro-USDC: divide by 1e6
```

Or: `./check-balances.sh <address>` prints ETH + USDC balances.

## 3. Hard-won lessons

- **Verify the token contract before you mint.** Read `decimals()` and check
  the contract on a block explorer first. There are many lookalike "USDC"
  contracts on testnet; only interact with the one your target protocol
  actually accepts.
- **Escrow/protocol deposits may credit on an epoch boundary.** Some testnet
  protocols acknowledge a deposit only at the next epoch: your balance shows
  up, but spendable actions return `402 Payment Required` for several minutes.
  Wait one epoch before concluding the deposit failed.
- **Test the payment gate before the real run.** A dry run that stops exactly
  at the payment step proves your whole pipeline (discovery → quoting →
  selection) works; funding is then the only remaining variable.
- **Keys shown once are gone forever.** Several dev platforms display an API
  key exactly once with no "list keys" page. Save it to a vault the moment it
  appears.

## Scripts

- `mint-test-usdc.sh <address> <amount>` — mint test USDC (needs `cast` and
  `SEPOLIA_PRIVATE_KEY` in the environment).
- `check-balances.sh <address>` — print Sepolia ETH + test USDC balances.

## License

MIT — see [LICENSE](LICENSE).
