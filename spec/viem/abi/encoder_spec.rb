# frozen_string_literal: true

RSpec.describe Viem::Abi::Encoder do
  let(:balanceOf_abi) do
    {
      "name"            => "balanceOf",
      "type"            => "function",
      "inputs"          => [{ "type" => "address", "name" => "account" }],
      "outputs"         => [{ "type" => "uint256", "name" => "" }],
      "stateMutability" => "view"
    }
  end

  let(:transfer_abi) do
    {
      "name"            => "transfer",
      "type"            => "function",
      "inputs"          => [
        { "type" => "address", "name" => "to" },
        { "type" => "uint256", "name" => "amount" }
      ],
      "outputs"         => [{ "type" => "bool", "name" => "" }],
      "stateMutability" => "nonpayable"
    }
  end

  describe ".get_selector" do
    it "returns 4-byte selector for balanceOf(address)" do
      selector = described_class.get_selector(balanceOf_abi)
      # keccak256("balanceOf(address)")[0..3]
      expect(selector).to eq("0x70a08231")
    end

    it "returns 4-byte selector for transfer(address,uint256)" do
      selector = described_class.get_selector(transfer_abi)
      expect(selector).to eq("0xa9059cbb")
    end
  end

  describe ".encode_abi_parameters" do
    it "encodes a uint256 value" do
      result = described_class.encode_abi_parameters(["uint256"], [42])
      expect(result).to start_with("0x")
      expect(result.length).to eq(2 + 64) # 0x + 32 bytes
    end

    it "encodes an address" do
      addr   = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
      result = described_class.encode_abi_parameters(["address"], [addr])
      expect(result).to start_with("0x")
      expect(result.downcase).to include("d8da6bf26964af9d7eed9e03e53415d37aa96045")
    end
  end

  describe ".encode_function_data" do
    it "encodes balanceOf call" do
      addr   = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
      result = described_class.encode_function_data(balanceOf_abi, args: [addr])
      expect(result).to start_with("0x70a08231")
      expect(result.length).to eq(2 + 8 + 64) # 0x + selector + 32 bytes
    end

    it "encodes with no args" do
      abi = {
        "name"   => "totalSupply",
        "type"   => "function",
        "inputs" => [],
        "outputs" => [{ "type" => "uint256", "name" => "" }]
      }
      result = described_class.encode_function_data(abi, args: [])
      expect(result).to start_with("0x")
      expect(result.length).to eq(10) # 0x + 8 hex chars (4 bytes)
    end
  end

  describe ".encode_deploy_data" do
    let(:bytecode) { "0x6080604052" }

    it "returns bytecode when no constructor args" do
      result = described_class.encode_deploy_data(bytecode)
      expect(result).to eq(bytecode)
    end

    it "appends encoded constructor args" do
      constructor_abi = {
        "type"   => "constructor",
        "inputs" => [{ "type" => "uint256", "name" => "initialSupply" }]
      }
      result = described_class.encode_deploy_data(bytecode, constructor_abi, args: [1000])
      expect(result).to start_with("0x6080604052")
      expect(result.length).to be > bytecode.length
    end
  end
end
