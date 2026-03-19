# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module GetTransaction
        def get_transaction(hash:)
          result = @transport.request("eth_getTransactionByHash", [hash])
          raise TransactionNotFoundError, "Transaction #{hash} not found" unless result

          format_transaction(result)
        end

        def get_transaction_receipt(hash:)
          result = @transport.request("eth_getTransactionReceipt", [hash])
          raise TransactionReceiptNotFoundError, "Receipt for #{hash} not found" unless result

          format_receipt(result)
        end

        def get_transaction_count(address:, block_tag: "latest")
          address = Utils::Address.get_address(address)
          result  = @transport.request("eth_getTransactionCount", [address, block_tag.to_s])
          Utils::Hex.hex_to_number(result)
        end

        def wait_for_transaction_receipt(hash:, poll_interval: 4, timeout: 120)
          deadline = Time.now + timeout
          loop do
            receipt = @transport.request("eth_getTransactionReceipt", [hash])
            return format_receipt(receipt) if receipt

            if Time.now > deadline
              raise WaitForTransactionReceiptTimeoutError,
                    "Timeout after #{timeout}s waiting for #{hash}"
            end

            sleep poll_interval
          end
        end

        private

        def format_transaction(raw)
          raw.transform_keys(&:to_sym).tap do |tx|
            tx[:block_number]      = Utils::Hex.hex_to_number(tx[:blockNumber])      if tx[:blockNumber]
            tx[:transaction_index] = Utils::Hex.hex_to_number(tx[:transactionIndex]) if tx[:transactionIndex]
            tx[:nonce]             = Utils::Hex.hex_to_number(tx[:nonce])             if tx[:nonce]
            tx[:gas]               = Utils::Hex.hex_to_number(tx[:gas])               if tx[:gas]
            tx[:gas_price]         = Utils::Hex.hex_to_number(tx[:gasPrice])          if tx[:gasPrice]
            tx[:value]             = Utils::Hex.hex_to_number(tx[:value])             if tx[:value]
          end
        end

        def format_receipt(raw)
          raw.transform_keys(&:to_sym).tap do |r|
            r[:block_number]         = Utils::Hex.hex_to_number(r[:blockNumber])        if r[:blockNumber]
            r[:transaction_index]    = Utils::Hex.hex_to_number(r[:transactionIndex])   if r[:transactionIndex]
            r[:gas_used]             = Utils::Hex.hex_to_number(r[:gasUsed])            if r[:gasUsed]
            r[:cumulative_gas_used]  = Utils::Hex.hex_to_number(r[:cumulativeGasUsed])  if r[:cumulativeGasUsed]
            r[:status]               = Utils::Hex.hex_to_number(r[:status])             if r[:status]
            r[:logs]                 = (r[:logs] || []).map { |l| format_log(l) }
          end
        end

        def format_log(raw)
          raw.transform_keys(&:to_sym).tap do |l|
            l[:block_number]      = Utils::Hex.hex_to_number(l[:blockNumber])      if l[:blockNumber]
            l[:transaction_index] = Utils::Hex.hex_to_number(l[:transactionIndex]) if l[:transactionIndex]
            l[:log_index]         = Utils::Hex.hex_to_number(l[:logIndex])         if l[:logIndex]
          end
        end
      end
    end
  end
end
