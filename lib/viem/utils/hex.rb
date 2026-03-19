# frozen_string_literal: true

module Viem
  module Utils
    module Hex
      def self.is_hex?(value, strict: false)
        return false unless value.is_a?(String)

        if strict
          value.match?(/\A0x[0-9a-fA-F]+\z/)
        else
          value.match?(/\A0x[0-9a-fA-F]*\z/)
        end
      end

      def self.to_hex(value, size: nil)
        hex = case value
              when Integer
                value.negative? ? twos_complement(value) : value.to_s(16)
              when String
                value.unpack1("H*")
              when Array
                value.pack("C*").unpack1("H*")
              else
                raise ArgumentError, "Cannot convert #{value.class} to hex"
              end
        hex = hex.rjust(size * 2, "0") if size
        "0x#{hex}"
      end

      def self.hex_to_number(hex)
        strip(hex).to_i(16)
      end

      def self.number_to_hex(num, size: nil)
        to_hex(num, size: size)
      end

      def self.hex_to_bytes(hex)
        [strip(hex)].pack("H*").bytes
      end

      def self.bytes_to_hex(bytes)
        "0x#{bytes.pack("C*").unpack1("H*")}"
      end

      def self.hex_to_string(hex)
        [strip(hex)].pack("H*")
      end

      def self.string_to_hex(str)
        "0x#{str.unpack1("H*")}"
      end

      def self.strip(hex)
        hex.delete_prefix("0x")
      end

      private_class_method def self.twos_complement(value)
        bits = value.bit_length + 1
        bits += (8 - (bits % 8)) if (bits % 8) != 0
        ((2**bits) + value).to_s(16)
      end
    end
  end
end
