# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module GetBalance
        def get_balance(address:, block_tag: "latest")
          address = Utils::Address.get_address(address)
          result  = @transport.request("eth_getBalance", [address, block_tag.to_s])
          Utils::Hex.hex_to_number(result)
        end
      end
    end
  end
end
