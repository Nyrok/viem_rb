# frozen_string_literal: true

module Viem
  module Chains
    Chain = Struct.new(
      :id, :name, :network, :native_currency,
      :rpc_urls, :block_explorers, :testnet,
      keyword_init: true
    ) do
      def rpc_url
        rpc_urls.dig(:default, :http, 0)
      end

      def testnet?
        !!testnet
      end
    end

    NativeCurrency = Struct.new(:name, :symbol, :decimals, keyword_init: true)
  end
end
