# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module Call
        def call(to:, data: nil, from: nil, value: nil, gas: nil, block_tag: "latest")
          params = {}
          params[:to]    = to    if to
          params[:from]  = from  if from
          params[:data]  = data  if data
          params[:value] = Utils::Hex.number_to_hex(value) if value
          params[:gas]   = Utils::Hex.number_to_hex(gas)   if gas
          @transport.request("eth_call", [stringify_keys(params), block_tag.to_s])
        end

        def estimate_gas(to:, from: nil, data: nil, value: nil)
          params = {}
          params[:to]    = to    if to
          params[:from]  = from  if from
          params[:data]  = data  if data
          params[:value] = Utils::Hex.number_to_hex(value) if value
          result = @transport.request("eth_estimateGas", [stringify_keys(params)])
          Utils::Hex.hex_to_number(result)
        end

        private

        def stringify_keys(h)
          h.transform_keys { |k| k.to_s.gsub(/_([a-z])/) { ::Regexp.last_match(1).upcase } }
        end
      end
    end
  end
end
