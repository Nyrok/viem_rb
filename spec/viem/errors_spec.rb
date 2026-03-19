# frozen_string_literal: true

RSpec.describe "Viem error hierarchy" do
  it "Viem::Error inherits from StandardError" do
    expect(Viem::Error.ancestors).to include(StandardError)
  end

  it "Viem::TransportError is a Viem::Error" do
    expect(Viem::TransportError.ancestors).to include(Viem::Error)
  end

  it "Viem::HttpRequestError is a Viem::TransportError" do
    expect(Viem::HttpRequestError.ancestors).to include(Viem::TransportError)
  end

  it "Viem::RpcError is a Viem::Error" do
    expect(Viem::RpcError.ancestors).to include(Viem::Error)
  end

  it "Viem::UserRejectedError is a Viem::RpcError" do
    expect(Viem::UserRejectedError.ancestors).to include(Viem::RpcError)
  end

  describe Viem::HttpRequestError do
    it "stores status and body" do
      err = described_class.new("bad request", status: 400, body: "Bad Request")
      expect(err.status).to eq(400)
      expect(err.body).to eq("Bad Request")
      expect(err.message).to eq("bad request")
    end

    it "can be raised and rescued as TransportError" do
      expect do
        raise Viem::HttpRequestError.new("timeout", status: 503)
      end.to raise_error(Viem::TransportError)
    end
  end

  describe Viem::RpcError do
    it "stores code and data" do
      err = described_class.new("execution reverted", code: -32_603, data: "0x")
      expect(err.code).to eq(-32_603)
      expect(err.data).to eq("0x")
    end
  end

  describe Viem::ContractFunctionExecutionError do
    it "formats a message with the function name" do
      cause = RuntimeError.new("revert ERC20: insufficient balance")
      err   = described_class.new(
        cause,
        contract_address: "0xA0b8...",
        function_name:    "transfer",
        args:             ["0xRecipient", 1000]
      )
      expect(err.message).to include("transfer")
      expect(err.cause).to eq(cause)
      expect(err.function_name).to eq("transfer")
      expect(err.args).to eq(["0xRecipient", 1000])
    end
  end

  describe Viem::InvalidAddressError do
    it "includes the invalid address in the message" do
      err = described_class.new("not-an-address")
      expect(err.message).to include("not-an-address")
    end
  end

  describe Viem::AccountRequiredError do
    it "has a descriptive message" do
      err = described_class.new
      expect(err.message).to include("account")
    end
  end

  it "raises and rescues leaf errors as Viem::Error" do
    [
      Viem::AbiEncodingError,
      Viem::AbiDecodingError,
      Viem::ChainMismatchError,
      Viem::BlockNotFoundError,
      Viem::TransactionNotFoundError,
      Viem::TransactionReceiptNotFoundError,
      Viem::WaitForTransactionReceiptTimeoutError
    ].each do |klass|
      expect { raise klass }.to raise_error(Viem::Error)
    end
  end
end
