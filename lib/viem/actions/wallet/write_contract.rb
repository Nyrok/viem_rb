# frozen_string_literal: true

module Viem
  module Actions
    module Wallet
      module WriteContract
        def write_contract(
          address:,
          abi:,
          function_name:,
          args: [],
          value: nil,
          gas: nil,
          gas_price: nil,
          max_fee_per_gas: nil,
          max_priority_fee_per_gas: nil,
          account: nil
        )
          acct = account || @account
          raise AccountRequiredError unless acct

          abi_item = find_abi_item(abi, function_name, type: "function")
          data     = Abi::Encoder.encode_function_data(abi_item, args: args)

          send_transaction(
            to: address, data: data, value: value || 0,
            gas: gas, gas_price: gas_price,
            max_fee_per_gas: max_fee_per_gas,
            max_priority_fee_per_gas: max_priority_fee_per_gas,
            account: acct,
          )
        rescue RpcError => e
          raise ContractFunctionExecutionError.new(e,
                                                   contract_address: address, function_name: function_name, args: args,)
        end

        def deploy_contract(abi:, bytecode:, args: [], value: nil, gas: nil, account: nil)
          acct = account || @account
          raise AccountRequiredError unless acct

          constructor = abi.find { |i| i["type"] == "constructor" }
          data        = Abi::Encoder.encode_deploy_data(bytecode, constructor, args: args)
          send_transaction(to: nil, data: data, value: value || 0, gas: gas, account: acct)
        end
      end
    end
  end
end
