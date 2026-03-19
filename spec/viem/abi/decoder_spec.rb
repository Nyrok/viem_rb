# frozen_string_literal: true

RSpec.describe Viem::Abi::Decoder do
  describe ".decode_abi_parameters" do
    it "decodes a uint256" do
      encoded = Viem::Abi::Encoder.encode_abi_parameters(["uint256"], [42])
      result  = described_class.decode_abi_parameters(["uint256"], encoded)
      expect(result).to eq([42])
    end

    it "decodes an address" do
      addr    = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
      encoded = Viem::Abi::Encoder.encode_abi_parameters(["address"], [addr])
      result  = described_class.decode_abi_parameters(["address"], encoded)
      expect(result.first.downcase).to eq(addr.downcase)
    end

    it "decodes multiple types" do
      addr    = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
      encoded = Viem::Abi::Encoder.encode_abi_parameters(%w[uint256 address], [999, addr])
      result  = described_class.decode_abi_parameters(%w[uint256 address], encoded)
      expect(result[0]).to eq(999)
      expect(result[1].downcase).to eq(addr.downcase)
    end

    it "decodes a bool true" do
      encoded = Viem::Abi::Encoder.encode_abi_parameters(["bool"], [true])
      result  = described_class.decode_abi_parameters(["bool"], encoded)
      expect(result).to eq([true])
    end

    it "raises AbiDecodingError on invalid data" do
      expect { described_class.decode_abi_parameters(["uint256"], "0xinvalid") }
        .to raise_error(Viem::AbiDecodingError)
    end
  end

  describe ".decode_function_result" do
    let(:balanceOf_abi) do
      {
        "name" => "balanceOf",
        "type" => "function",
        "inputs" => [{ "type" => "address", "name" => "account" }],
        "outputs" => [{ "type" => "uint256", "name" => "" }],
      }
    end

    let(:transfer_abi) do
      {
        "name" => "transfer",
        "type" => "function",
        "inputs" => [],
        "outputs" => [
          { "type" => "address", "name" => "to" },
          { "type" => "uint256", "name" => "amount" },
        ],
      }
    end

    it "returns single value directly for single-output functions" do
      encoded = Viem::Abi::Encoder.encode_abi_parameters(["uint256"], [1_000_000])
      result  = described_class.decode_function_result(balanceOf_abi, encoded)
      expect(result).to eq(1_000_000)
    end

    it "returns array for multi-output functions" do
      addr    = "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
      encoded = Viem::Abi::Encoder.encode_abi_parameters(%w[address uint256], [addr, 500])
      result  = described_class.decode_function_result(transfer_abi, encoded)
      expect(result).to be_an(Array)
      expect(result[1]).to eq(500)
    end

    it "handles empty outputs gracefully" do
      abi     = { "name" => "doSomething", "type" => "function", "inputs" => [], "outputs" => [] }
      result  = described_class.decode_function_result(abi, "0x")
      expect(result).to eq([])
    end
  end
end
