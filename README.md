# @yamo/contracts

Smart contracts for the YAMO Protocol.

## Overview

The YAMO contracts package contains Solidity smart contracts for storing and verifying YAMO blocks on EVM-compatible blockchains. The contracts use OpenZeppelin's UUPS (Universal Upgradeable Proxy Standard) pattern for upgradeability.

## Contracts

### YAMORegistryV2

The main contract for YAMO block storage and verification.

**Key Features:**
- UUPS upgradeable pattern
- Block submission with content hash and IPFS CID
- Block verification
- Event emission for indexing
- Access control

**Main Functions:**
- `submitBlockV2`: Submit a block with IPFS CID
- `verifyBlock`: Verify a block's content hash
- `blocks`: Query block metadata
- `upgradeToAndCall`: Upgrade contract implementation

## Installation

```bash
npm install
```

## Development

### Compile Contracts

```bash
npm run build
```

### Run Tests

```bash
npm test
```

### Deploy Locally

Start a local Hardhat node:

```bash
npx hardhat node
```

In another terminal, deploy the contracts:

```bash
npm run deploy:local
```

### Deploy to Sepolia

Configure `.env` with your credentials:

```env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
PRIVATE_KEY=your_private_key
```

Deploy:

```bash
npm run deploy:sepolia
```

## Contract Architecture

```
YAMORegistry (Base contract)
    ↓ extends
YAMORegistryV2 (adds IPFS CID support)
    ↓ deployed via
UUPS Proxy (upgradeable)
```

## Security

- Contracts use OpenZeppelin's audited libraries
- UUPS pattern ensures controlled upgradeability
- Access control via Ownable pattern
- Comprehensive test coverage

## License

MIT
