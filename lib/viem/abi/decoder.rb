# frozen_string_literal: true

require "eth"

module Viem
  module Abi
    module Decoder
      def self.decode_abi_parameters(types, data)
        data = data.delete_prefix("0x")
        Eth::Abi.decode(types, [data].pack("H*"))
      rescue Eth::Abi::DecodingError => e
        raise AbiDecodingError, e.message
      end

      def self.decode_function_result(abi_item, data)
        types  = (abi_item["outputs"] || []).map { |o| o["type"] }
        result = decode_abi_parameters(types, data)
        # Return single value if one output, array otherwise
        result.length == 1 ? result.first : result
      end

      def self.decode_error_result(abi_item, data)
        types = (abi_item["inputs"] || []).map { |i| i["type"] }
        decode_abi_parameters(types, data[10..]) # skip 4-byte selector
      end
    end
  end
end
