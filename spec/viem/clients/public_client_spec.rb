# frozen_string_literal: true

RSpec.describe Viem::Clients::PublicClient do
  let(:rpc_url)   { "https://eth-mainnet.example.com" }
  let(:transport) { Viem::Transports::Http.new(rpc_url) }
  let(:client)    { described_class.new(transport: transport, chain: Viem::MAINNET) }

  # Helper to stub JSON-RPC calls via WebMock
  def stub_rpc(method, result:, params: anything)
    stub_request(:post, rpc_url)
      .with(body: hash_including("method" => method))
      .to_return(
        status: 200,
        body: { jsonrpc: "2.0", id: 1, result: result }.to_json,
        headers: { "Content-Type" => "application/json" },
      )
  end

  def stub_rpc_error(method, code:, message:)
    stub_request(:post, rpc_url)
      .with(body: hash_including("method" => method))
      .to_return(
        status: 200,
        body: { jsonrpc: "2.0", id: 1, error: { code: code, message: message } }.to_json,
        headers: { "Content-Type" => "application/json" },
      )
  end

  describe "#chain_id" do
    it "returns the chain ID as an integer" do
      stub_rpc("eth_chainId", result: "0x1")
      expect(client.chain_id).to eq(1)
    end
  end

  describe "#get_network" do
    it "returns chain_id and name" do
      stub_rpc("eth_chainId", result: "0x1")
      network = client.get_network
      expect(network[:chain_id]).to eq(1)
      expect(network[:name]).to eq("Ethereum")
    end
  end

  describe "#get_balance" do
    let(:address) { "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045" }

    it "returns the balance as an integer (wei)" do
      stub_rpc("eth_getBalance", result: "0xde0b6b3a7640000")
      balance = client.get_balance(address: address)
      expect(balance).to eq(1_000_000_000_000_000_000)
    end

    it "raises InvalidAddressError for an invalid address" do
      expect { client.get_balance(address: "not-an-address") }
        .to raise_error(Viem::InvalidAddressError)
    end
  end

  describe "#get_block_number" do
    it "returns the current block number" do
      stub_rpc("eth_blockNumber", result: "0x100")
      expect(client.get_block_number).to eq(256)
    end
  end

  describe "#get_block" do
    let(:raw_block) do
      {
        "number" => "0x1",
        "hash" => "0xabc",
        "parentHash" => "0x000",
        "timestamp" => "0x64c8f3b4",
        "gasLimit" => "0x1c9c380",
        "gasUsed" => "0x0",
        "baseFeePerGas" => "0x7",
        "transactions" => [],
      }
    end

    it "returns a formatted block hash" do
      stub_rpc("eth_getBlockByNumber", result: raw_block)
      block = client.get_block
      expect(block[:number]).to eq(1)
      expect(block[:hash]).to eq("0xabc")
    end

    it "raises BlockNotFoundError when result is nil" do
      stub_rpc("eth_getBlockByNumber", result: nil)
      expect { client.get_block(block_number: 9_999_999) }
        .to raise_error(Viem::BlockNotFoundError)
    end

    it "fetches block by number" do
      stub_rpc("eth_getBlockByNumber", result: raw_block)
      block = client.get_block(block_number: 1)
      expect(block[:number]).to eq(1)
    end

    it "fetches block by hash" do
      stub_rpc("eth_getBlockByHash", result: raw_block)
      block = client.get_block(block_hash: "0xabc")
      expect(block[:hash]).to eq("0xabc")
    end
  end

  describe "#get_transaction" do
    let(:raw_tx) do
      {
        "hash" => "0xtxhash",
        "blockNumber" => "0xa",
        "transactionIndex" => "0x0",
        "nonce" => "0x5",
        "gas" => "0x5208",
        "gasPrice" => "0x3b9aca00",
        "value" => "0xde0b6b3a7640000",
        "from" => "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
        "to" => "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
        "input" => "0x",
      }
    end

    it "returns a formatted transaction" do
      stub_rpc("eth_getTransactionByHash", result: raw_tx)
      tx = client.get_transaction(hash: "0xtxhash")
      expect(tx[:nonce]).to eq(5)
      expect(tx[:value]).to eq(1_000_000_000_000_000_000)
      expect(tx[:gas]).to eq(21_000)
    end

    it "raises TransactionNotFoundError when result is nil" do
      stub_rpc("eth_getTransactionByHash", result: nil)
      expect { client.get_transaction(hash: "0xnotfound") }
        .to raise_error(Viem::TransactionNotFoundError)
    end
  end

  describe "#get_transaction_receipt" do
    let(:raw_receipt) do
      {
        "transactionHash" => "0xtxhash",
        "blockNumber" => "0xa",
        "transactionIndex" => "0x0",
        "gasUsed" => "0x5208",
        "cumulativeGasUsed" => "0x5208",
        "status" => "0x1",
        "logs" => [],
        "from" => "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
        "to" => "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
      }
    end

    it "returns a formatted receipt" do
      stub_rpc("eth_getTransactionReceipt", result: raw_receipt)
      receipt = client.get_transaction_receipt(hash: "0xtxhash")
      expect(receipt[:status]).to eq(1)
      expect(receipt[:gas_used]).to eq(21_000)
      expect(receipt[:logs]).to eq([])
    end

    it "raises TransactionReceiptNotFoundError when result is nil" do
      stub_rpc("eth_getTransactionReceipt", result: nil)
      expect { client.get_transaction_receipt(hash: "0xnotfound") }
        .to raise_error(Viem::TransactionReceiptNotFoundError)
    end
  end

  describe "#get_transaction_count" do
    it "returns the nonce as an integer" do
      stub_rpc("eth_getTransactionCount", result: "0x5")
      count = client.get_transaction_count(address: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
      expect(count).to eq(5)
    end
  end

  describe "#get_gas_price" do
    it "returns the gas price as an integer" do
      stub_rpc("eth_gasPrice", result: "0x3b9aca00")
      expect(client.get_gas_price).to eq(1_000_000_000)
    end
  end

  describe "#get_code" do
    let(:address) { "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045" }

    it "returns the bytecode when non-empty" do
      stub_rpc("eth_getCode", result: "0x6080604052")
      code = client.get_code(address: address)
      expect(code).to eq("0x6080604052")
    end

    it "returns nil for an EOA (empty bytecode)" do
      stub_rpc("eth_getCode", result: "0x")
      code = client.get_code(address: address)
      expect(code).to be_nil
    end
  end

  describe "#get_storage_at" do
    let(:address) { "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045" }

    it "returns the storage slot value" do
      stub_rpc("eth_getStorageAt", result: "0x0000000000000000000000000000000000000000000000000000000000000001")
      result = client.get_storage_at(address: address, slot: 0)
      expect(result).to eq("0x0000000000000000000000000000000000000000000000000000000000000001")
    end
  end

  describe "#estimate_gas" do
    it "returns estimated gas as an integer" do
      stub_rpc("eth_estimateGas", result: "0x5208")
      gas = client.estimate_gas(
        to: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
        from: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
      )
      expect(gas).to eq(21_000)
    end
  end

  describe "#call" do
    it "sends eth_call and returns the raw result" do
      stub_rpc("eth_call", result: "0x0000000000000000000000000000000000000000000000000000000000000001")
      result = client.call(
        to: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
        data: "0x70a08231000000000000000000000000d8da6bf26964af9d7eed9e03e53415d37aa96045",
      )
      expect(result).to start_with("0x")
    end
  end

  describe "RPC error handling" do
    it "raises RpcError when the node returns an error" do
      stub_rpc_error("eth_chainId", code: -32_603, message: "Internal error")
      expect { client.chain_id }.to raise_error(Viem::RpcError, "Internal error")
    end
  end

  describe "#get_logs" do
    it "returns formatted logs" do
      raw_log = {
        "address" => "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
        "topics" => ["0xddf252ad"],
        "data" => "0x",
        "blockNumber" => "0xa",
        "transactionIndex" => "0x0",
        "logIndex" => "0x0",
        "transactionHash" => "0xtxhash",
        "blockHash" => "0xblockhash",
        "removed" => false,
      }
      stub_rpc("eth_getLogs", result: [raw_log])
      logs = client.get_logs(from_block: 0, to_block: 10)
      expect(logs).to be_an(Array)
      expect(logs.first[:block_number]).to eq(10)
      expect(logs.first[:log_index]).to eq(0)
    end

    it "returns an empty array when there are no logs" do
      stub_rpc("eth_getLogs", result: [])
      logs = client.get_logs
      expect(logs).to eq([])
    end
  end
end
