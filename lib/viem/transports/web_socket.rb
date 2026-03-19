# frozen_string_literal: true

require "websocket-client-simple"
require "json"

module Viem
  module Transports
    class WebSocket < Base
      def initialize(url, timeout: 30)
        @url     = url
        @timeout = timeout
        @pending = {}
        @mutex   = Mutex.new
        @id      = 0
        connect
      end

      def request(method, params = [])
        id   = next_id
        body = build_rpc_body(method, params, id)
        q    = Queue.new
        @mutex.synchronize { @pending[id] = q }
        @ws.send(body.to_json)
        result = q.pop(timeout: @timeout)
        raise TransportError, "WebSocket timeout waiting for response to #{method}" if result.nil?
        raise RpcError.new(result[:error][:message], code: result[:error][:code]) if result[:error]

        result[:result]
      end

      def close
        @ws.close
      end

      private

      def next_id
        @mutex.synchronize { @id += 1 }
      end

      def connect
        url     = @url
        pending = @pending
        mutex   = @mutex

        @ws = ::WebSocket::Client::Simple.connect(url) do |ws|
          ws.on :message do |msg|
            data = JSON.parse(msg.data, symbolize_names: true)
            q    = mutex.synchronize { pending.delete(data[:id]) }
            q&.push(data)
          end

          ws.on :error do |e|
            mutex.synchronize do
              pending.each_value { |q| q.push({ error: { message: e.message, code: -32_000 } }) }
            end
          end
        end

        sleep 0.1 # let connection establish
      end
    end
  end
end
