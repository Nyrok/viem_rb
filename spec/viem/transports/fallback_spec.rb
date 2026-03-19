# frozen_string_literal: true

RSpec.describe Viem::Transports::Fallback do
  let(:rpc_url_primary)   { "https://primary.example.com" }
  let(:rpc_url_secondary) { "https://secondary.example.com" }
  let(:primary)   { Viem::Transports::Http.new(rpc_url_primary) }
  let(:secondary) { Viem::Transports::Http.new(rpc_url_secondary) }

  def stub_rpc(url, result:)
    stub_request(:post, url).to_return(
      status: 200,
      body: { jsonrpc: "2.0", id: 1, result: result }.to_json,
      headers: { "Content-Type" => "application/json" },
    )
  end

  def stub_rpc_failure(url)
    stub_request(:post, url).to_raise(Faraday::ConnectionFailed.new("connection refused"))
  end

  describe "#initialize" do
    it "raises ArgumentError when no transports are provided" do
      expect { described_class.new }.to raise_error(ArgumentError, /At least one transport/)
    end

    it "accepts one or more transports" do
      expect { described_class.new(primary) }.not_to raise_error
      expect { described_class.new(primary, secondary) }.not_to raise_error
    end
  end

  describe "#request" do
    it "returns the result from the primary transport when it succeeds" do
      stub_rpc(rpc_url_primary, result: "0x1")
      transport = described_class.new(primary, secondary)
      expect(transport.request("eth_chainId")).to eq("0x1")
    end

    it "falls back to secondary when primary fails" do
      stub_rpc_failure(rpc_url_primary)
      stub_rpc(rpc_url_secondary, result: "0x1")
      transport = described_class.new(primary, secondary)
      expect(transport.request("eth_chainId")).to eq("0x1")
    end

    it "raises the last error when all transports fail" do
      stub_rpc_failure(rpc_url_primary)
      stub_rpc_failure(rpc_url_secondary)
      transport = described_class.new(primary, secondary)
      expect { transport.request("eth_chainId") }.to raise_error(Viem::TransportError)
    end

    it "works with a single transport that succeeds" do
      stub_rpc(rpc_url_primary, result: "0xff")
      transport = described_class.new(primary)
      expect(transport.request("eth_blockNumber")).to eq("0xff")
    end
  end
end
