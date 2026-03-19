# frozen_string_literal: true

require "eth"

module Viem
  module Abi
    module Encoder
      def self.encode_abi_parameters(types, values)
        encoded = Eth::Abi.encode(types, values)
        "0x#{encoded.unpack1("H*")}"
      rescue Eth::Abi::EncodingError => e
        raise AbiEncodingError, e.message
      end

      def self.encode_function_data(abi_item, args: [])
        sig      = function_signature(abi_item)
        selector = Eth::Util.keccak256(sig)[0, 4]
        types    = (abi_item["inputs"] || []).map { |i| i["type"] }
        encoded  = Eth::Abi.encode(types, args)
        "0x#{selector.unpack1("H*")}#{encoded.unpack1("H*")}"
      rescue Eth::Abi::EncodingError => e
        raise AbiEncodingError, e.message
      end

      def self.encode_deploy_data(bytecode, abi_item = nil, args: [])
        bytecode = bytecode.delete_prefix("0x")
        return "0x#{bytecode}" if abi_item.nil? || args.empty?

        types   = (abi_item["inputs"] || []).map { |i| i["type"] }
        encoded = Eth::Abi.encode(types, args)
        "0x#{bytecode}#{encoded.unpack1("H*")}"
      rescue Eth::Abi::EncodingError => e
        raise AbiEncodingError, e.message
      end

      def self.get_selector(abi_item)
        sig = function_signature(abi_item)
        "0x#{Eth::Util.keccak256(sig)[0, 4].unpack1("H*")}"
      end

      def self.function_signature(abi_item)
        inputs = (abi_item["inputs"] || []).map { |i| i["type"] }.join(",")
        "#{abi_item["name"]}(#{inputs})"
      end
      private_class_method :function_signature
    end
  end
end
