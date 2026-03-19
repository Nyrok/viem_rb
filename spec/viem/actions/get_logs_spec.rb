# frozen_string_literal: true

RSpec.describe Viem::Actions::Public::GetLogs do
  let(:rpc_url)   { "https://eth-mainnet.example.com" }
  let(:transport) { Viem::Transports::Http.new(rpc_url) }
  let(:client)    { Viem::Clients::PublicClient.new(transport: transport, chain: Viem::MAINNET) }

  let(:contract_address) { "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48" }
  let(:from_address)     { "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045" }
  let(:to_address)       { "0x1234567890123456789012345678901234567890" }

  let(:transfer_event_abi) do
    {
      "name" => "Transfer",
      "type" => "event",
      "inputs" => [
        { "type" => "address", "name" => "from",  "indexed" => true },
        { "type" => "address", "name" => "to",    "indexed" => true },
        { "type" => "uint256", "name" => "value", "indexed" => false },
      ],
    }
  end

  let(:approval_event_abi) do
    {
      "name" => "Approval",
      "type" => "event",
      "inputs" => [
        { "type" => "address", "name" => "owner",   "indexed" => true },
        { "type" => "address", "name" => "spender", "indexed" => true },
        { "type" => "uint256", "name" => "value",   "indexed" => false },
      ],
    }
  end

  let(:raw_log) do
    {
      "address" => contract_address,
      "topics" => ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"],
      "data" => "0x0000000000000000000000000000000000000000000000000000000000002710",
      "blockNumber" => "0x100",
      "transactionHash" => "0xabc",
      "transactionIndex" => "0x1",
      "blockHash" => "0xblockhash",
      "logIndex" => "0x2",
      "removed" => false,
    }
  end

  def stub_eth_get_logs(result:)
    stub_request(:post, rpc_url)
      .with(body: hash_including("method" => "eth_getLogs"))
      .to_return(
        status: 200,
        body: { jsonrpc: "2.0", id: 1, result: result }.to_json,
        headers: { "Content-Type" => "application/json" },
      )
  end

  def capture_request_body(&block)
    body = nil
    stub_request(:post, rpc_url).with(body: hash_including("method" => "eth_getLogs")) do |req|
      body = JSON.parse(req.body)
      true
    end.to_return(
      status: 200,
      body: { jsonrpc: "2.0", id: 1, result: [] }.to_json,
      headers: { "Content-Type" => "application/json" },
    )
    block.call
    body
  end

  # ── Basic response formatting ─────────────────────────────────────────────

  describe "response formatting" do
    it "returns an empty array when no logs are found" do
      stub_eth_get_logs(result: [])
      expect(client.get_logs).to eq([])
    end

    it "formats log fields to snake_case with integer conversions" do
      stub_eth_get_logs(result: [raw_log])
      log = client.get_logs.first
      expect(log[:block_number]).to eq(256)
      expect(log[:log_index]).to eq(2)
      expect(log[:transaction_index]).to eq(1)
    end

    it "preserves address, topics, data and removed fields" do
      stub_eth_get_logs(result: [raw_log])
      log = client.get_logs.first
      expect(log[:address]).to eq(contract_address)
      expect(log[:topics]).to be_an(Array)
      expect(log[:removed]).to be false
    end

    it "returns multiple logs" do
      stub_eth_get_logs(result: [raw_log, raw_log])
      expect(client.get_logs.length).to eq(2)
    end
  end

  # ── Block range parameters ────────────────────────────────────────────────

  describe "block range parameters" do
    it "encodes integer from_block to hex" do
      body = capture_request_body { client.get_logs(from_block: 1_000) }
      expect(body.dig("params", 0, "fromBlock")).to eq("0x3e8")
    end

    it "encodes integer to_block to hex" do
      body = capture_request_body { client.get_logs(to_block: 2_000) }
      expect(body.dig("params", 0, "toBlock")).to eq("0x7d0")
    end

    it "passes string block tags through unchanged" do
      body = capture_request_body { client.get_logs(from_block: "latest", to_block: "latest") }
      expect(body.dig("params", 0, "fromBlock")).to eq("latest")
      expect(body.dig("params", 0, "toBlock")).to eq("latest")
    end

    it "omits fromBlock/toBlock when not provided" do
      body = capture_request_body { client.get_logs }
      expect(body.dig("params", 0)).not_to have_key("fromBlock")
      expect(body.dig("params", 0)).not_to have_key("toBlock")
    end
  end

  # ── block_hash filter ─────────────────────────────────────────────────────

  describe "block_hash filter" do
    it "sends blockHash param instead of fromBlock/toBlock" do
      body = capture_request_body { client.get_logs(block_hash: "0xdeadbeef") }
      expect(body.dig("params", 0, "blockHash")).to eq("0xdeadbeef")
      expect(body.dig("params", 0)).not_to have_key("fromBlock")
      expect(body.dig("params", 0)).not_to have_key("toBlock")
    end

    it "raises ArgumentError when block_hash is combined with from_block" do
      stub_eth_get_logs(result: [])
      expect { client.get_logs(block_hash: "0xabc", from_block: 100) }
        .to raise_error(ArgumentError, /mutually exclusive/)
    end

    it "raises ArgumentError when block_hash is combined with to_block" do
      stub_eth_get_logs(result: [])
      expect { client.get_logs(block_hash: "0xabc", to_block: 200) }
        .to raise_error(ArgumentError, /mutually exclusive/)
    end
  end

  # ── Address filtering ─────────────────────────────────────────────────────

  describe "address filtering" do
    it "validates and checksums a single address" do
      body = capture_request_body { client.get_logs(address: contract_address.downcase) }
      expect(body.dig("params", 0, "address")).to match(/\A0x[0-9a-fA-F]{40}\z/)
    end

    it "accepts an array of addresses" do
      body = capture_request_body { client.get_logs(address: [contract_address, from_address]) }
      expect(body.dig("params", 0, "address")).to be_an(Array)
      expect(body.dig("params", 0, "address").length).to eq(2)
    end

    it "raises InvalidAddressError for an invalid address" do
      expect { client.get_logs(address: "not-an-address") }
        .to raise_error(Viem::InvalidAddressError)
    end

    it "omits address when not provided" do
      body = capture_request_body { client.get_logs }
      expect(body.dig("params", 0)).not_to have_key("address")
    end
  end

  # ── Event topic0 ─────────────────────────────────────────────────────────

  describe "event topic0 encoding" do
    it "encodes topic0 as keccak256 of the event signature" do
      # keccak256("Transfer(address,address,uint256)")
      expected_topic0 = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
      body = capture_request_body { client.get_logs(event: transfer_event_abi) }
      expect(body.dig("params", 0, "topics", 0)).to eq(expected_topic0)
    end

    it "encodes Approval event topic0 correctly" do
      expected_topic0 = "0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"
      body = capture_request_body { client.get_logs(event: approval_event_abi) }
      expect(body.dig("params", 0, "topics", 0)).to eq(expected_topic0)
    end

    it "sends only topic0 when no indexed args are provided" do
      body = capture_request_body { client.get_logs(event: transfer_event_abi) }
      expect(body.dig("params", 0, "topics").length).to eq(1)
    end
  end

  # ── Indexed args (topic1, topic2) ────────────────────────────────────────

  describe "indexed args encoding" do
    it "encodes an address arg as a left-padded 32-byte topic" do
      body = capture_request_body do
        client.get_logs(event: transfer_event_abi, args: { "from" => from_address })
      end
      topic1 = body.dig("params", 0, "topics", 1)
      expect(topic1).to start_with("0x000000000000000000000000")
      expect(topic1.downcase).to include(from_address.delete_prefix("0x").downcase)
    end

    it "accepts symbol keys for args" do
      body = capture_request_body do
        client.get_logs(event: transfer_event_abi, args: { from: from_address })
      end
      expect(body.dig("params", 0, "topics", 1)).not_to be_nil
    end

    it "encodes two indexed address args into topic1 and topic2" do
      body = capture_request_body do
        client.get_logs(
          event: transfer_event_abi,
          args: { "from" => from_address, "to" => to_address },
        )
      end
      expect(body.dig("params", 0, "topics").length).to eq(3)
      expect(body.dig("params", 0, "topics", 1)).not_to be_nil
      expect(body.dig("params", 0, "topics", 2)).not_to be_nil
    end

    it "inserts nil wildcard when an indexed arg is not specified" do
      body = capture_request_body do
        client.get_logs(event: transfer_event_abi, args: { "to" => to_address })
      end
      topics = body.dig("params", 0, "topics")
      expect(topics[1]).to be_nil # from = wildcard
      expect(topics[2]).not_to be_nil # to = filtered
    end

    it "strips trailing nil wildcards from topics" do
      body = capture_request_body do
        client.get_logs(event: transfer_event_abi, args: { "from" => from_address })
      end
      # Only topic0 + topic1 (from), no trailing nil for `to`
      expect(body.dig("params", 0, "topics").length).to eq(2)
    end
  end

  # ── OR filtering (array args) ─────────────────────────────────────────────

  describe "OR filtering for indexed args" do
    it "encodes an array of values as an OR topic filter" do
      body = capture_request_body do
        client.get_logs(
          event: transfer_event_abi,
          args: { "from" => [from_address, to_address] },
        )
      end
      topic1 = body.dig("params", 0, "topics", 1)
      expect(topic1).to be_an(Array)
      expect(topic1.length).to eq(2)
    end
  end

  # ── Raw topics override ───────────────────────────────────────────────────

  describe "raw topics override" do
    it "passes raw topics directly without event encoding" do
      raw_topics = ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", nil]
      body = capture_request_body { client.get_logs(topics: raw_topics) }
      expect(body.dig("params", 0, "topics")).to eq(raw_topics)
    end

    it "ignores event when raw topics are provided" do
      raw_topics = ["0xcustom_topic"]
      body = capture_request_body do
        client.get_logs(event: transfer_event_abi, topics: raw_topics)
      end
      expect(body.dig("params", 0, "topics")).to eq(raw_topics)
    end
  end

  # ── Tuple events (canonical type) ────────────────────────────────────────

  describe "canonical type resolution for tuple events" do
    let(:tuple_event_abi) do
      {
        "name" => "OrderFilled",
        "type" => "event",
        "inputs" => [
          {
            "type" => "tuple",
            "name" => "order",
            "indexed" => false,
            "components" => [
              { "type" => "address", "name" => "maker" },
              { "type" => "uint256", "name" => "amount" },
            ],
          },
        ],
      }
    end

    it "builds the correct canonical signature for tuple events" do
      body = capture_request_body { client.get_logs(event: tuple_event_abi) }
      topic0 = body.dig("params", 0, "topics", 0)
      # keccak256("OrderFilled((address,uint256))")
      expected = Viem::Utils::Hash.keccak256("OrderFilled((address,uint256))")
      expect(topic0).to eq(expected)
    end
  end

  # ── encode_topic_value unit tests ─────────────────────────────────────────

  describe "topic value encoding" do
    subject { client }

    it "encodes bool true" do
      event_abi = {
        "name" => "FlagSet", "type" => "event",
        "inputs" => [{ "type" => "bool", "name" => "flag", "indexed" => true }],
      }
      body = capture_request_body { client.get_logs(event: event_abi, args: { "flag" => true }) }
      expect(body.dig("params", 0, "topics", 1)).to eq("0x#{"0" * 63}1")
    end

    it "encodes bool false" do
      event_abi = {
        "name" => "FlagSet", "type" => "event",
        "inputs" => [{ "type" => "bool", "name" => "flag", "indexed" => true }],
      }
      body = capture_request_body { client.get_logs(event: event_abi, args: { "flag" => false }) }
      expect(body.dig("params", 0, "topics", 1)).to eq("0x#{"0" * 64}")
    end

    it "encodes uint256 value" do
      event_abi = {
        "name" => "Threshold", "type" => "event",
        "inputs" => [{ "type" => "uint256", "name" => "value", "indexed" => true }],
      }
      body = capture_request_body { client.get_logs(event: event_abi, args: { "value" => 1000 }) }
      topic = body.dig("params", 0, "topics", 1)
      expect(topic).to start_with("0x")
      expect(topic.length).to eq(66) # 0x + 64 hex chars
    end

    it "encodes bytes32 value right-padded to 32 bytes" do
      event_abi = {
        "name" => "HashSet", "type" => "event",
        "inputs" => [{ "type" => "bytes32", "name" => "hash", "indexed" => true }],
      }
      body = capture_request_body { client.get_logs(event: event_abi, args: { "hash" => "0xdeadbeef" }) }
      topic = body.dig("params", 0, "topics", 1)
      expect(topic).to start_with("0xdeadbeef")
      expect(topic.length).to eq(66)
    end
  end
end
