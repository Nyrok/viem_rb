# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module GetLogs
        # Fetch event logs from the chain.
        #
        # @param address    [String, Array<String>, nil]  Contract address(es) to filter
        # @param event      [Hash, nil]                   ABI item for the event (generates topic0)
        # @param args       [Hash]                        Indexed argument values to filter (topic1+).
        #                                                 Values can be arrays for OR filtering.
        # @param from_block [Integer, String, nil]        Start block (number, "latest", "earliest", "pending")
        # @param to_block   [Integer, String, nil]        End block
        # @param block_hash [String, nil]                 Filter by specific block hash (exclusive with from/to)
        # @param topics     [Array, nil]                  Raw topics override (skips event+args encoding)
        #
        # @return [Array<Hash>] Formatted log objects
        def get_logs(
          address: nil,
          event: nil,
          args: {},
          from_block: nil,
          to_block: nil,
          block_hash: nil,
          topics: nil
        )
          raise ArgumentError, "block_hash is mutually exclusive with from_block/to_block" \
            if block_hash && (from_block || to_block)

          params = {}

          params[:address] = encode_address_filter(address) if address

          if block_hash
            params[:blockHash] = block_hash
          else
            params[:fromBlock] = encode_block_param(from_block) if from_block
            params[:toBlock]   = encode_block_param(to_block)   if to_block
          end

          encoded_topics = topics || (event ? encode_event_topics(event, args) : nil)
          params[:topics] = encoded_topics if encoded_topics

          results = @transport.request("eth_getLogs", [stringify_keys(params)])
          results.map { |l| format_log(l) }
        end

        private

        # Encode address or array of addresses, validating each one.
        def encode_address_filter(address)
          if address.is_a?(Array)
            address.map { |a| Utils::Address.get_address(a) }
          else
            Utils::Address.get_address(address)
          end
        end

        # Convert block param to hex string or pass through string tags.
        def encode_block_param(value)
          return value if value.is_a?(String)

          Utils::Hex.number_to_hex(value)
        end

        # Build topics array from event ABI + args.
        # topic0 = keccak256(event signature)
        # topic1+ = encoded indexed argument values (nil = wildcard)
        def encode_event_topics(event_abi, args)
          topic0 = Utils::Hash.keccak256(event_signature(event_abi))
          topics = [topic0]

          indexed_inputs = (event_abi["inputs"] || []).select { |i| i["indexed"] }
          indexed_inputs.each do |input|
            name  = input["name"]
            value = if args.is_a?(Hash)
                      args.key?(name) ? args[name] : args[name.to_sym]
                    end

            topics << if value.nil?
                        nil # wildcard — match any value for this topic position
                      elsif value.is_a?(Array)
                        value.map { |v| encode_topic_value(input["type"], v) }
                      else
                        encode_topic_value(input["type"], value)
                      end
          end

          # Strip trailing wildcards to keep the request minimal
          topics.reverse.drop_while(&:nil?).reverse
        end

        # ABI-encode a single indexed value to a 32-byte hex topic.
        def encode_topic_value(type, value)
          case type
          when "address"
            addr = Utils::Address.get_address(value).delete_prefix("0x").downcase
            "0x#{"0" * 24}#{addr}"
          when "bool"
            value ? "0x#{"0" * 63}1" : "0x#{"0" * 64}"
          when /\Auint\d*\z/, /\Aint\d*\z/
            Abi::Encoder.encode_abi_parameters([type], [value])
          when /\Abytes(\d+)\z/
            raw = value.delete_prefix("0x")
            "0x#{raw.ljust(64, "0")}"
          when "bytes", "string"
            # Dynamic types are stored as keccak256 of their content
            Utils::Hash.keccak256(value)
          else
            value
          end
        end

        # Build canonical event signature string for keccak256 hashing.
        def event_signature(abi_item)
          inputs = (abi_item["inputs"] || []).map { |i| canonical_type(i) }.join(",")
          "#{abi_item["name"]}(#{inputs})"
        end

        # Resolve tuple types to their canonical form for signature hashing.
        def canonical_type(input)
          return input["type"] unless input["type"] == "tuple"

          inner = (input["components"] || []).map { |c| canonical_type(c) }.join(",")
          "(#{inner})"
        end
      end
    end
  end
end
