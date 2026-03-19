# frozen_string_literal: true

module Viem
  module Clients
    class WalletClient < PublicClient
      include Actions::Wallet::SendTransaction
      include Actions::Wallet::SignMessage
      include Actions::Wallet::WriteContract
      include Actions::Wallet::SignTypedData

      attr_reader :account

      def initialize(transport:, chain: nil, account: nil)
        super(transport: transport, chain: chain)
        @account = account
      end

      def get_addresses
        return [@account.address] if @account

        @transport.request("eth_accounts", [])
      end
    end
  end
end
