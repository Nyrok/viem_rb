# frozen_string_literal: true

require "faraday"
require "json"

module Viem
  module Transports
    class Http < Base
      attr_reader :url

      def initialize(url, headers: {}, timeout: 30)
        @url     = url
        @headers = headers
        @timeout = timeout
        @mutex   = Mutex.new
        @conn    = build_connection
      end

      def request(method, params = [])
        body = build_rpc_body(method, params)
        resp = @mutex.synchronize { @conn.post("/", body.to_json) }
        unless resp.success?
          raise HttpRequestError.new("HTTP #{resp.status}", status: resp.status, body: resp.body)
        end

        parse_response(resp.body)
      rescue Faraday::Error => e
        raise TransportError, e.message
      end

      private

      def build_connection
        Faraday.new(url: @url) do |f|
          f.headers["Content-Type"] = "application/json"
          f.headers["User-Agent"]   = "viem_rb/#{Viem::VERSION}"
          @headers.each { |k, v| f.headers[k.to_s] = v }
          f.options.timeout      = @timeout
          f.options.open_timeout = 10
          f.adapter Faraday.default_adapter
        end
      end
    end
  end
end
