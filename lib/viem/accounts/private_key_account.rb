# frozen_string_literal: true

require "eth"

module Viem
  module Accounts
    class PrivateKeyAccount
      attr_reader :address, :type

      def initialize(private_key)
        private_key = private_key.delete_prefix("0x")
        @key     = Eth::Key.new(priv: private_key)
        @address = Eth::Address.new(@key.address.to_s).checksummed
        @type    = :local
      end

      def sign_message(message)
        prefixed = "\x19Ethereum Signed Message:\n#{message.bytesize}#{message}"
        hash     = Eth::Util.keccak256(prefixed)
        sig      = @key.sign(hash)
        "0x#{sig.unpack1("H*")}"
      end

      def sign_transaction(tx_hash)
        @key.sign(tx_hash)
      end

      def sign_typed_data(domain, types, value)
        # EIP-712 encoding
        encoded = Eth::Eip712.encode(domain, types, value)
        hash    = Eth::Util.keccak256(encoded)
        sig     = @key.sign(hash)
        "0x#{sig.unpack1("H*")}"
      rescue => e
        raise Error, "Failed to sign typed data: #{e.message}"
      end

      def public_key
        @key.public_hex
      end

      def private_key
        "0x#{@key.private_hex}"
      end

      def to_h
        { address: @address, type: @type }
      end
    end
  end
end
