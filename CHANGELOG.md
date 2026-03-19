# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-01

### Added

- Initial release
- `PublicClient` with full read-only Ethereum JSON-RPC actions
- `WalletClient` extending `PublicClient` with signing and transaction submission
- `TestClient` extending `PublicClient` with Anvil/Hardhat test node helpers
- HTTP transport (`Viem::Transports::Http`) using Faraday, thread-safe with Mutex
- WebSocket transport (`Viem::Transports::WebSocket`) using websocket-client-simple
- Fallback transport (`Viem::Transports::Fallback`) for automatic failover
- `PrivateKeyAccount` for local key management and signing
- ABI encoding/decoding via the `eth` gem
- Human-readable ABI parser (`Viem::Abi::Parse`)
- Hex utilities (`Viem::Utils::Hex`)
- Unit conversion utilities (`Viem::Utils::Units`) — parse/format Ether, Gwei, and arbitrary decimals
- Address utilities (`Viem::Utils::Address`) — validation and EIP-55 checksum
- Hash utilities (`Viem::Utils::Hash`) — keccak256, hash_message, sha256
- Full error hierarchy under `Viem::Error`
- 18 pre-configured chain definitions (Mainnet, Sepolia, Polygon, Optimism, Arbitrum, Base, Avalanche, BSC, Gnosis, Fantom, Celo, and their testnets)
- ENS resolution (`get_ens_address`, `get_ens_name`)
