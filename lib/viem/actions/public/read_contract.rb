# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module ReadContract
        def read_contract(address:, abi:, function_name:, args: [], block_tag: "latest")
          abi_item = find_abi_item(abi, function_name, type: "function")
          data     = Abi::Encoder.encode_function_data(abi_item, args: args)
          result   = call(to: address, data: data, block_tag: block_tag)
          Abi::Decoder.decode_function_result(abi_item, result)
        rescue RpcError => e
          raise ContractFunctionExecutionError.new(e,
                                                   contract_address: address, function_name: function_name, args: args,)
        end

        def simulate_contract(address:, abi:, function_name:, args: [], account: nil, value: nil, block_tag: "latest")
          abi_item = find_abi_item(abi, function_name, type: "function")
          data     = Abi::Encoder.encode_function_data(abi_item, args: args)
          from     = account&.address
          result   = call(to: address, data: data, from: from, value: value, block_tag: block_tag)
          Abi::Decoder.decode_function_result(abi_item, result)
        rescue RpcError => e
          raise ContractFunctionExecutionError.new(e,
                                                   contract_address: address, function_name: function_name, args: args,)
        end

        private

        def find_abi_item(abi, name, type: nil)
          item = abi.find do |i|
            i["name"] == name.to_s && (type.nil? || i["type"] == type)
          end
          raise AbiEncodingError, "Function '#{name}' not found in ABI" unless item

          item
        end
      end
    end
  end
end
