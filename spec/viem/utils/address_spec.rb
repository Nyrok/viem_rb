# frozen_string_literal: true

RSpec.describe Viem::Utils::Address do
  let(:valid_address)    { "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045" }
  let(:lowercase_addr)   { "0xd8da6bf26964af9d7eed9e03e53415d37aa96045" }
  let(:invalid_address)  { "0xinvalid" }
  let(:zero_addr)        { "0x0000000000000000000000000000000000000000" }

  describe ".is_address?" do
    it "returns true for a valid checksummed address" do
      expect(described_class.is_address?(valid_address)).to be true
    end

    it "returns true for a lowercase address" do
      expect(described_class.is_address?(lowercase_addr)).to be true
    end

    it "returns false for an invalid address" do
      expect(described_class.is_address?(invalid_address)).to be false
    end

    it "returns false for nil" do
      expect(described_class.is_address?(nil)).to be false
    end

    it "returns false for integers" do
      expect(described_class.is_address?(42)).to be false
    end

    it "returns false for an empty string" do
      expect(described_class.is_address?("")).to be false
    end
  end

  describe ".get_address" do
    it "returns checksummed address for a valid address" do
      result = described_class.get_address(lowercase_addr)
      # Should be EIP-55 checksummed
      expect(result).to match(/\A0x[0-9a-fA-F]{40}\z/)
    end

    it "raises InvalidAddressError for an invalid address" do
      expect { described_class.get_address(invalid_address) }
        .to raise_error(Viem::InvalidAddressError, /Invalid Ethereum address/)
    end

    it "raises InvalidAddressError for nil" do
      expect { described_class.get_address(nil) }
        .to raise_error(Viem::InvalidAddressError)
    end
  end

  describe ".zero_address" do
    it "returns the zero address" do
      expect(described_class.zero_address).to eq(zero_addr)
    end
  end

  describe ".is_zero_address?" do
    it "returns true for the zero address" do
      expect(described_class.is_zero_address?(zero_addr)).to be true
    end

    it "returns true for uppercase zero address" do
      expect(described_class.is_zero_address?(zero_addr.upcase.sub("0X", "0x"))).to be true
    end

    it "returns false for a non-zero address" do
      expect(described_class.is_zero_address?(valid_address)).to be false
    end
  end
end
