# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module GetBlock
        def get_block(block_number: nil, block_hash: nil, block_tag: "latest", include_transactions: false)
          if block_hash
            result = @transport.request("eth_getBlockByHash", [block_hash, include_transactions])
          else
            tag    = block_number ? Utils::Hex.number_to_hex(block_number) : block_tag.to_s
            result = @transport.request("eth_getBlockByNumber", [tag, include_transactions])
          end
          raise BlockNotFoundError, "Block not found" unless result

          format_block(result)
        end

        def get_block_number
          result = @transport.request("eth_blockNumber", [])
          Utils::Hex.hex_to_number(result)
        end

        private

        # Fields that should remain as hex strings (hashes, addresses)
        BLOCK_STRING_FIELDS = %w[
          hash parentHash sha3Uncles miner stateRoot transactionsRoot
          receiptsRoot logsBloom mixHash nonce extraData
        ].freeze

        def format_block(raw)
          raw.each_with_object({}) do |(k, v), h|
            key = k.to_sym
            h[key] = if BLOCK_STRING_FIELDS.include?(k.to_s)
                       v
                     elsif v.is_a?(String) && v.start_with?("0x") && v.match?(/\A0x[0-9a-f]+\z/)
                       Utils::Hex.hex_to_number(v)
                     else
                       v
                     end
          end
        end
      end
    end
  end
end
