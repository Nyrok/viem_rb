# frozen_string_literal: true

module Viem
  module Clients
    class PublicClient
      include Actions::Public::GetBalance
      include Actions::Public::GetBlock
      include Actions::Public::GetTransaction
      include Actions::Public::Call
      include Actions::Public::ReadContract
      include Actions::Public::GetLogs
      include Actions::Public::GetGas
      include Actions::Public::GetCode
      include Actions::Public::Ens

      attr_reader :transport, :chain

      def initialize(transport:, chain: nil)
        @transport = transport
        @chain     = chain
      end

      def chain_id
        result = @transport.request("eth_chainId", [])
        Utils::Hex.hex_to_number(result)
      end

      def get_network
        { chain_id: chain_id, name: @chain&.name }
      end

      private

      def stringify_keys(h)
        h.transform_keys { |k| k.to_s.gsub(/_([a-z])/) { ::Regexp.last_match(1).upcase } }
      end
    end
  end
end
