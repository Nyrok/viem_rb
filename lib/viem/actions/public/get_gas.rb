# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module GetGas
        def get_gas_price
          result = @transport.request("eth_gasPrice", [])
          Utils::Hex.hex_to_number(result)
        end

        def get_fee_history(block_count:, newest_block: "latest", reward_percentiles: [])
          result = @transport.request("eth_feeHistory", [
            Utils::Hex.number_to_hex(block_count),
            newest_block.to_s,
            reward_percentiles
          ])
          result
        end

        def get_max_priority_fee_per_gas
          result = @transport.request("eth_maxPriorityFeePerGas", [])
          Utils::Hex.hex_to_number(result)
        rescue RpcError
          # Fallback: estimate from fee history
          history = get_fee_history(block_count: 4, newest_block: "latest", reward_percentiles: [50])
          rewards = (history["reward"] || []).flatten.map { |r| Utils::Hex.hex_to_number(r) }
          rewards.sum / [rewards.size, 1].max
        end
      end
    end
  end
end
