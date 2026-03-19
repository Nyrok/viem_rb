# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2026-03-19

### Added
- `get_logs` fully completed:
  - `block_hash:` param — filter logs from a specific block hash (mutually exclusive with `from_block`/`to_block`)
  - Multi-address support — `address:` now accepts an array of contract addresses
  - Address validation on `address:` param (raises `InvalidAddressError` for invalid inputs)
  - Full indexed args encoding — `args:` hash now encodes topic1/2/3 by type (`address`, `bool`, `uint`, `int`, `bytes32`, `bytes`, `string`)
  - OR filtering — pass an array as an arg value to generate a multi-value OR topic filter
  - Raw `topics:` override — bypass event/args encoding and pass topics directly
  - Tuple event support — canonical type resolution for events with `tuple` inputs
  - Trailing nil wildcard stripping — topics array is trimmed to the last meaningful filter
- 31 new specs for `get_logs` (192 total, 0 failures)

## [0.1.2] - 2026-03-19

### Fixed
- Bumped minimum required Ruby version to `>= 3.0.0` (transitive dependency `rbsecp256k1` via `eth` is incompatible with Ruby < 3.0)
- CI matrix updated to Ruby 3.0–3.3, RuboCop on 3.3
- Fixed all RuboCop offenses across lib and spec files
- Fixed invalid cop name `Style/TrailingCommaInArgList` → `Style/TrailingCommaInArguments`

## [0.1.1] - 2026-03-19

### Added
- Extended test suite: ABI decoder, ABI parser, Hash utils, error hierarchy, chain definitions, and Fallback transport specs (161 examples total)
- GitHub Actions CI workflow — tests on Ruby 3.0 through 3.3, RuboCop on 3.3
- GitHub Actions publish workflow — auto-publishes to RubyGems on GitHub release

### Fixed
- Corrected author name from `Noryk` to `Nyrok` in gemspec, README and LICENSE

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
