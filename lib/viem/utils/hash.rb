# frozen_string_literal: true

require "eth"
require "digest"

module Viem
  module Utils
    module Hash
      def self.keccak256(data)
        bytes = if data.is_a?(String) && data.start_with?("0x")
                  [data.delete_prefix("0x")].pack("H*")
                else
                  data.to_s
                end
        "0x#{Eth::Util.keccak256(bytes).unpack1("H*")}"
      end

      def self.hash_message(message)
        keccak256("\x19Ethereum Signed Message:\n#{message.bytesize}#{message}")
      end

      def self.sha256(data)
        "0x#{Digest::SHA256.hexdigest(data.to_s)}"
      end
    end
  end
end
