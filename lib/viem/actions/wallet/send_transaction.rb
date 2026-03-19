# frozen_string_literal: true

module Viem
  module Actions
    module Wallet
      module SendTransaction
        def send_transaction(
          to:,
          value: 0,
          data: nil,
          gas: nil,
          gas_price: nil,
          max_fee_per_gas: nil,
          max_priority_fee_per_gas: nil,
          nonce: nil,
          account: nil
        )
          acct = account || @account
          raise AccountRequiredError unless acct

          nonce     ||= get_transaction_count(address: acct.address)
          chain_id    = @chain&.id || get_chain_id

          if max_fee_per_gas
            gas ||= begin
              estimate_gas(to: to, from: acct.address, data: data, value: value)
            rescue StandardError
              21_000
            end
            tx = build_eip1559_tx(
              to: to, value: value, data: data, gas: gas,
              max_fee_per_gas: max_fee_per_gas,
              max_priority_fee_per_gas: max_priority_fee_per_gas,
              nonce: nonce, chain_id: chain_id
            )
          else
            gas       ||= begin
              estimate_gas(to: to, from: acct.address, data: data, value: value)
            rescue StandardError
              21_000
            end
            gas_price ||= get_gas_price
            tx = build_legacy_tx(
              to: to, value: value, data: data, gas: gas,
              gas_price: gas_price, nonce: nonce, chain_id: chain_id
            )
          end

          signed = sign_tx(acct, tx)
          @transport.request("eth_sendRawTransaction", [signed])
        end

        private

        def get_chain_id
          result = @transport.request("eth_chainId", [])
          Utils::Hex.hex_to_number(result)
        end

        def build_eip1559_tx(to:, value:, data:, gas:, max_fee_per_gas:, max_priority_fee_per_gas:, nonce:, chain_id:)
          Eth::Tx::Eip1559.new({
            chain_id:                 chain_id,
            nonce:                    nonce,
            max_priority_fee_per_gas: max_priority_fee_per_gas || Utils::Units.parse_gwei("1.5"),
            max_fee_per_gas:          max_fee_per_gas,
            gas_limit:                gas,
            to:                       to,
            value:                    value,
            data:                     data || ""
          })
        end

        def build_legacy_tx(to:, value:, data:, gas:, gas_price:, nonce:, chain_id:)
          Eth::Tx::Legacy.new({
            chain_id:  chain_id,
            nonce:     nonce,
            gas_price: gas_price,
            gas_limit: gas,
            to:        to,
            value:     value,
            data:      data || ""
          })
        end

        def sign_tx(account, tx)
          tx.sign(Eth::Key.new(priv: account.private_key.delete_prefix("0x")))
          "0x#{tx.hex}"
        end
      end
    end
  end
end
