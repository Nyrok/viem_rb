# frozen_string_literal: true

require "json"

module Viem
  module Transports
    class Base
      def request(method, params = [])
        raise NotImplementedError
      end

      private

      def build_rpc_body(method, params, id = 1)
        { jsonrpc: "2.0", id: id, method: method, params: params }
      end

      def parse_response(body)
        data = body.is_a?(String) ? JSON.parse(body, symbolize_names: true) : body
        raise Viem::RpcError.new(data[:error][:message], code: data[:error][:code]) if data[:error]

        data[:result]
      end
    end
  end
end
