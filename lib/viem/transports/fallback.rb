# frozen_string_literal: true

module Viem
  module Transports
    class Fallback < Base
      def initialize(*transports)
        raise ArgumentError, "At least one transport required" if transports.empty?

        @transports = transports
      end

      def request(method, params = [])
        last_error = nil
        @transports.each do |t|
          return t.request(method, params)
        rescue TransportError, RpcError => e
          last_error = e
          next
        end
        raise last_error || TransportError.new("All transports failed")
      end
    end
  end
end
