# viem_rb

[![Gem Version](https://img.shields.io/gem/v/viem_rb.svg)](https://rubygems.org/gems/viem_rb)
[![Gem Downloads](https://img.shields.io/gem/dt/viem_rb.svg)](https://rubygems.org/gems/viem_rb)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0-red.svg)](https://www.ruby-lang.org)

📦 **[https://rubygems.org/gems/viem_rb](https://rubygems.org/gems/viem_rb)**

A Ruby/Rails adaptation of [viem](https://viem.sh) — the TypeScript Ethereum library. Provides Ethereum clients, ABI encoding/decoding, account management, and utilities for Ruby 3.0+ and Rails 7+ applications.

## Installation

Add to your Gemfile:

```ruby
gem "viem_rb"
```

Or install directly:

```bash
gem install viem_rb
```

## Quick Start

### Public Client (read-only)

```ruby
require "viem_rb"

# Create a transport
transport = Viem.http("https://cloudflare-eth.com")

# Create a public client
client = Viem.create_public_client(
  transport: transport,
  chain: Viem::MAINNET
)

# Read the chain ID
client.chain_id  # => 1

# Get ETH balance
balance = client.get_balance(address: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
# => 1000000000000000000 (in wei)

Viem::Utils::Units.format_ether(balance)  # => "1.0"

# Get current block
block = client.get_block
# => { number: 18_000_000, hash: "0x...", timestamp: 1_700_000_000, ... }

# Get block by number
client.get_block(block_number: 17_000_000)

# Get transaction
tx = client.get_transaction(hash: "0xabc...")

# Get transaction receipt
receipt = client.get_transaction_receipt(hash: "0xabc...")

# Read a contract
erc20_abi = [
  { "name" => "balanceOf", "type" => "function",
    "inputs" => [{ "type" => "address", "name" => "account" }],
    "outputs" => [{ "type" => "uint256", "name" => "" }],
    "stateMutability" => "view" }
]

balance = client.read_contract(
  address:       "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",  # USDC
  abi:           erc20_abi,
  function_name: "balanceOf",
  args:          ["0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"]
)
```

### Wallet Client (read + write)

```ruby
# Create an account from a private key
account = Viem.private_key_to_account("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80")
# => #<Viem::Accounts::PrivateKeyAccount address="0xf39Fd6e...">

transport = Viem.http("https://mainnet.example.com")

client = Viem.create_wallet_client(
  transport: transport,
  chain:     Viem::MAINNET,
  account:   account
)

# Sign a message
sig = client.sign_message(message: "Hello, Ethereum!")
# => "0x..."

# Send ETH
tx_hash = client.send_transaction(
  to:    "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  value: Viem::Utils::Units.parse_ether("0.01")
)

# Write to a contract
erc20_abi = [...] # full ABI

tx_hash = client.write_contract(
  address:       "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  abi:           erc20_abi,
  function_name: "transfer",
  args:          ["0xRecipient...", 1_000_000]  # 1 USDC (6 decimals)
)

# Wait for receipt
receipt = client.wait_for_transaction_receipt(hash: tx_hash, timeout: 60)
```

### WebSocket Transport

```ruby
transport = Viem.web_socket("wss://mainnet.infura.io/ws/v3/YOUR_KEY")
client    = Viem.create_public_client(transport: transport)
```

### Fallback Transport

```ruby
transport = Viem.fallback(
  Viem.http("https://primary-rpc.com"),
  Viem.http("https://backup-rpc.com")
)
client = Viem.create_public_client(transport: transport)
```

### Test Client (Anvil / Hardhat)

```ruby
transport = Viem.http("http://localhost:8545")
test_client = Viem.create_test_client(transport: transport)

test_client.mine(blocks: 5)
test_client.set_balance(address: "0x...", value: Viem::Utils::Units.parse_ether("100"))
test_client.impersonate_account(address: "0x...")

id = test_client.snapshot
# ... do stuff ...
test_client.revert(id: id)
```

## Actions Reference

### Public Client Actions

| Method | Description |
|--------|-------------|
| `get_balance(address:, block_tag: "latest")` | Get ETH balance in wei |
| `get_block(block_number:, block_hash:, block_tag:, include_transactions:)` | Get block by number, hash, or tag |
| `get_block_number` | Get current block number |
| `get_transaction(hash:)` | Get transaction by hash |
| `get_transaction_receipt(hash:)` | Get receipt by tx hash |
| `get_transaction_count(address:, block_tag:)` | Get nonce for address |
| `wait_for_transaction_receipt(hash:, poll_interval:, timeout:)` | Poll for receipt |
| `call(to:, data:, from:, value:, gas:, block_tag:)` | Execute eth_call |
| `estimate_gas(to:, from:, data:, value:)` | Estimate gas for a tx |
| `read_contract(address:, abi:, function_name:, args:, block_tag:)` | Read a contract function |
| `simulate_contract(...)` | Simulate a state-changing function |
| `get_logs(address:, event:, args:, from_block:, to_block:)` | Fetch event logs |
| `get_gas_price` | Get current gas price in wei |
| `get_fee_history(block_count:, newest_block:, reward_percentiles:)` | Get EIP-1559 fee history |
| `get_max_priority_fee_per_gas` | Get suggested priority fee |
| `get_code(address:, block_tag:)` | Get contract bytecode |
| `get_storage_at(address:, slot:, block_tag:)` | Read a storage slot |
| `get_ens_address(name:)` | Resolve ENS name to address |
| `get_ens_name(address:)` | Reverse ENS lookup |
| `chain_id` | Get chain ID |
| `get_network` | Get network info |

### Wallet Client Actions

| Method | Description |
|--------|-------------|
| `send_transaction(to:, value:, data:, gas:, ...)` | Sign and send a transaction |
| `sign_message(message:, account:)` | Sign a personal message (EIP-191) |
| `sign_typed_data(domain:, types:, primary_type:, message:, account:)` | Sign EIP-712 typed data |
| `write_contract(address:, abi:, function_name:, args:, ...)` | Call a state-changing contract function |
| `deploy_contract(abi:, bytecode:, args:, ...)` | Deploy a contract |
| `get_addresses` | List accounts |

### Test Client Actions

| Method | Description |
|--------|-------------|
| `mine(blocks:, interval:)` | Mine blocks |
| `set_balance(address:, value:)` | Set ETH balance |
| `set_code(address:, bytecode:)` | Set contract code |
| `set_storage_at(address:, slot:, value:)` | Write a storage slot |
| `impersonate_account(address:)` | Impersonate any address |
| `stop_impersonating_account(address:)` | Stop impersonation |
| `snapshot` | Take EVM snapshot |
| `revert(id:)` | Revert to snapshot |
| `increase_time(seconds:)` | Advance time |
| `set_next_block_timestamp(timestamp:)` | Set next block's timestamp |
| `reset(url:, block_number:)` | Reset to a forked state |

## Utilities

### Hex

```ruby
Viem::Utils::Hex.to_hex(255)          # => "0xff"
Viem::Utils::Hex.hex_to_number("0xff") # => 255
Viem::Utils::Hex.is_hex?("0xabc")     # => true
Viem::Utils::Hex.string_to_hex("Hi")  # => "0x4869"
Viem::Utils::Hex.hex_to_string("0x4869") # => "Hi"
```

### Units

```ruby
Viem::Utils::Units.parse_ether("1")          # => 1000000000000000000
Viem::Utils::Units.format_ether(1_000_000_000_000_000_000) # => "1.0"
Viem::Utils::Units.parse_gwei("10")          # => 10000000000
Viem::Utils::Units.parse_units("1", 6)       # => 1000000 (USDC)
```

### Address

```ruby
Viem::Utils::Address.is_address?("0x...")   # => true/false
Viem::Utils::Address.get_address("0x...")   # => checksummed address
Viem::Utils::Address.zero_address           # => "0x000...000"
```

### Hash / Crypto

```ruby
Viem::Utils::Hash.keccak256("hello")       # => "0x1c8aff9..."
Viem::Utils::Hash.hash_message("Hello!")   # => EIP-191 hash
Viem::Utils::Hash.sha256("data")           # => "0x..."
```

### ABI

```ruby
# Encode
Viem::Abi::Encoder.encode_abi_parameters(["uint256", "address"], [100, "0x..."])
Viem::Abi::Encoder.encode_function_data(abi_item, args: [...])
Viem::Abi::Encoder.get_selector(abi_item)   # => "0x70a08231"

# Decode
Viem::Abi::Decoder.decode_abi_parameters(["uint256"], "0x...")
Viem::Abi::Decoder.decode_function_result(abi_item, "0x...")

# Parse human-readable ABI
Viem::Abi::Parse.parse_abi([
  "function balanceOf(address account) view returns (uint256)",
  "event Transfer(address indexed from, address indexed to, uint256 value)"
])
```

## Chains

All chains are accessible as constants:

```ruby
Viem::MAINNET          # Ethereum Mainnet (id: 1)
Viem::SEPOLIA          # Sepolia Testnet (id: 11155111)
Viem::GOERLI           # Goerli Testnet (id: 5)
Viem::POLYGON          # Polygon (id: 137)
Viem::POLYGON_MUMBAI   # Polygon Mumbai (id: 80001)
Viem::OPTIMISM         # Optimism (id: 10)
Viem::OPTIMISM_GOERLI  # Optimism Goerli (id: 420)
Viem::ARBITRUM         # Arbitrum One (id: 42161)
Viem::ARBITRUM_GOERLI  # Arbitrum Goerli (id: 421613)
Viem::BASE             # Base (id: 8453)
Viem::BASE_GOERLI      # Base Goerli (id: 84531)
Viem::AVALANCHE        # Avalanche C-Chain (id: 43114)
Viem::AVALANCHE_FUJI   # Avalanche Fuji (id: 43113)
Viem::BSC              # BNB Smart Chain (id: 56)
Viem::BSC_TESTNET      # BSC Testnet (id: 97)
Viem::GNOSIS           # Gnosis (id: 100)
Viem::FANTOM           # Fantom (id: 250)
Viem::CELO             # Celo (id: 42220)
```

Chain objects expose:

```ruby
Viem::MAINNET.id          # => 1
Viem::MAINNET.name        # => "Ethereum"
Viem::MAINNET.rpc_url     # => "https://cloudflare-eth.com"
Viem::MAINNET.testnet?    # => false
Viem::SEPOLIA.testnet?    # => true
```

## Error Handling

```ruby
begin
  client.get_balance(address: "invalid")
rescue Viem::InvalidAddressError => e
  puts e.message  # "Invalid Ethereum address: \"invalid\""
rescue Viem::RpcError => e
  puts "RPC error #{e.code}: #{e.message}"
rescue Viem::HttpRequestError => e
  puts "HTTP #{e.status}: #{e.body}"
rescue Viem::ContractFunctionExecutionError => e
  puts "Contract error in #{e.function_name}: #{e.cause.message}"
rescue Viem::TransportError => e
  puts "Transport failed: #{e.message}"
rescue Viem::Error => e
  puts "Viem error: #{e.message}"
end
```

### Error Hierarchy

```
Viem::Error
  Viem::TransportError
    Viem::HttpRequestError          (.status, .body)
  Viem::RpcError                    (.code, .data)
    Viem::UserRejectedError
  Viem::ContractFunctionExecutionError (.cause, .contract_address, .function_name, .args)
  Viem::AbiEncodingError
  Viem::AbiDecodingError
  Viem::InvalidAddressError
  Viem::ChainMismatchError
  Viem::AccountRequiredError
  Viem::BlockNotFoundError
  Viem::TransactionNotFoundError
  Viem::TransactionReceiptNotFoundError
  Viem::WaitForTransactionReceiptTimeoutError
```

## Rails Integration

Add to `config/initializers/viem.rb`:

```ruby
require "viem_rb"

ETHEREUM_CLIENT = Viem.create_public_client(
  transport: Viem.http(ENV.fetch("ETH_RPC_URL", "https://cloudflare-eth.com")),
  chain: Viem::MAINNET
)
```

Then in your models or services:

```ruby
class EthereumService
  def self.balance_of(address)
    ETHEREUM_CLIENT.get_balance(address: address)
  end
end
```

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Run the test suite: `bundle exec rspec`
4. Run the linter: `bundle exec rubocop`
5. Commit your changes: `git commit -m "Add my feature"`
6. Push to the branch: `git push origin feature/my-feature`
7. Create a Pull Request

## License

MIT License. Copyright 2025 Nyrok. See [LICENSE](LICENSE) for details.

---

*viem_rb is available on [RubyGems](https://rubygems.org/gems/viem_rb). Inspired by [viem](https://viem.sh).*
