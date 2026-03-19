# frozen_string_literal: true

require "json"
require_relative "viem/version"
require_relative "viem/errors"
require_relative "viem/chains/base"
require_relative "viem/chains/definitions"
require_relative "viem/transports/base"
require_relative "viem/transports/http"
require_relative "viem/transports/web_socket"
require_relative "viem/transports/fallback"
require_relative "viem/utils/address"
require_relative "viem/utils/hex"
require_relative "viem/utils/units"
require_relative "viem/utils/hash"
require_relative "viem/abi/encoder"
require_relative "viem/abi/decoder"
require_relative "viem/abi/parse"
require_relative "viem/accounts/private_key_account"
require_relative "viem/accounts/mnemonic_account"
require_relative "viem/actions/public/get_balance"
require_relative "viem/actions/public/get_block"
require_relative "viem/actions/public/get_transaction"
require_relative "viem/actions/public/call"
require_relative "viem/actions/public/read_contract"
require_relative "viem/actions/public/get_logs"
require_relative "viem/actions/public/get_gas"
require_relative "viem/actions/public/get_code"
require_relative "viem/actions/public/ens"
require_relative "viem/actions/wallet/send_transaction"
require_relative "viem/actions/wallet/sign_message"
require_relative "viem/actions/wallet/write_contract"
require_relative "viem/actions/wallet/sign_typed_data"
require_relative "viem/clients/public_client"
require_relative "viem/clients/wallet_client"
require_relative "viem/clients/test_client"

module Viem
  class << self
    def create_public_client(transport:, chain: nil)
      Clients::PublicClient.new(transport: transport, chain: chain)
    end

    def create_wallet_client(transport:, chain: nil, account: nil)
      Clients::WalletClient.new(transport: transport, chain: chain, account: account)
    end

    def create_test_client(transport:, chain: nil)
      Clients::TestClient.new(transport: transport, chain: chain)
    end

    def http(url, **opts)
      Transports::Http.new(url, **opts)
    end

    def web_socket(url, **opts)
      Transports::WebSocket.new(url, **opts)
    end

    def fallback(*transports)
      Transports::Fallback.new(*transports)
    end

    def private_key_to_account(private_key)
      Accounts::PrivateKeyAccount.new(private_key)
    end
  end

  # Expose chains at top-level: Viem::MAINNET, Viem::SEPOLIA, etc.
  include Chains
end
