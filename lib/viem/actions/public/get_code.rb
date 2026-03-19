# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module GetCode
        def get_code(address:, block_tag: "latest")
          address = Utils::Address.get_address(address)
          result  = @transport.request("eth_getCode", [address, block_tag.to_s])
          result == "0x" ? nil : result
        end

        def get_storage_at(address:, slot:, block_tag: "latest")
          address = Utils::Address.get_address(address)
          slot    = slot.is_a?(Integer) ? Utils::Hex.number_to_hex(slot, size: 32) : slot
          @transport.request("eth_getStorageAt", [address, slot, block_tag.to_s])
        end
      end
    end
  end
end
