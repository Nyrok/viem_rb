# frozen_string_literal: true

require "eth"

module Viem
  module Utils
    module Address
      def self.is_address?(value)
        return false unless value.is_a?(String)

        Eth::Address.new(value).valid?
      rescue
        false
      end

      def self.get_address(address)
        raise InvalidAddressError, address unless is_address?(address)

        Eth::Address.new(address).checksummed
      end

      def self.zero_address
        "0x0000000000000000000000000000000000000000"
      end

      def self.is_zero_address?(address)
        address.downcase == zero_address
      end
    end
  end
end
