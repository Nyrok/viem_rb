# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module GetLogs
        def get_logs(address: nil, event: nil, args: {}, from_block: nil, to_block: nil)
          params = {}
          params[:address]   = address if address
          params[:fromBlock] = from_block.is_a?(Integer) ? Utils::Hex.number_to_hex(from_block) : (from_block || "earliest")
          params[:toBlock]   = to_block.is_a?(Integer) ? Utils::Hex.number_to_hex(to_block) : (to_block || "latest")
          params[:topics]    = encode_event_topics(event, args) if event
          results = @transport.request("eth_getLogs", [stringify_keys(params)])
          results.map { |l| format_log(l) }
        end

        private

        def encode_event_topics(event_abi, args)
          sig    = event_signature(event_abi)
          topic0 = Utils::Hash.keccak256(sig)
          [topic0]
        end

        def event_signature(abi_item)
          inputs = (abi_item["inputs"] || []).map { |i| i["type"] }.join(",")
          "#{abi_item["name"]}(#{inputs})"
        end
      end
    end
  end
end
