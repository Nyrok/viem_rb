# frozen_string_literal: true

module Viem
  module Clients
    class TestClient < PublicClient
      def mine(blocks: 1, interval: 0)
        @transport.request("anvil_mine", [
          Utils::Hex.number_to_hex(blocks),
          Utils::Hex.number_to_hex(interval)
        ])
      end

      def set_balance(address:, value:)
        @transport.request("anvil_setBalance", [address, Utils::Hex.number_to_hex(value)])
      end

      def set_code(address:, bytecode:)
        @transport.request("anvil_setCode", [address, bytecode])
      end

      def set_storage_at(address:, slot:, value:)
        @transport.request("anvil_setStorageAt", [address, slot, value])
      end

      def impersonate_account(address:)
        @transport.request("anvil_impersonateAccount", [address])
      end

      def stop_impersonating_account(address:)
        @transport.request("anvil_stopImpersonatingAccount", [address])
      end

      def snapshot
        @transport.request("evm_snapshot", [])
      end

      def revert(id:)
        @transport.request("evm_revert", [id])
      end

      def increase_time(seconds:)
        @transport.request("evm_increaseTime", [seconds])
      end

      def set_next_block_timestamp(timestamp:)
        @transport.request("evm_setNextBlockTimestamp", [timestamp])
      end

      def reset(url: nil, block_number: nil)
        params = url ? [{ jsonRpcUrl: url, blockNumber: block_number }.compact] : []
        @transport.request("anvil_reset", params)
      end
    end
  end
end
