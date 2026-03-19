# frozen_string_literal: true

RSpec.describe Viem::Utils::Hash do
  describe ".keccak256" do
    it "hashes a plain string" do
      result = described_class.keccak256("hello")
      expect(result).to start_with("0x")
      expect(result.length).to eq(66) # 0x + 64 hex chars
    end

    it "returns the well-known keccak256 of empty string" do
      # keccak256("") = c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
      result = described_class.keccak256("")
      expect(result).to eq("0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470")
    end

    it "hashes a hex-encoded input" do
      result = described_class.keccak256("0xdeadbeef")
      expect(result).to start_with("0x")
      expect(result.length).to eq(66)
    end

    it "produces different hashes for different inputs" do
      expect(described_class.keccak256("foo")).not_to eq(described_class.keccak256("bar"))
    end
  end

  describe ".hash_message" do
    it "returns an EIP-191 prefixed hash" do
      result = described_class.hash_message("Hello!")
      expect(result).to start_with("0x")
      expect(result.length).to eq(66)
    end

    it "produces a different hash than raw keccak256" do
      msg = "test"
      expect(described_class.hash_message(msg)).not_to eq(described_class.keccak256(msg))
    end

    it "is deterministic" do
      expect(described_class.hash_message("same")).to eq(described_class.hash_message("same"))
    end
  end

  describe ".sha256" do
    it "returns a sha256 hex digest with 0x prefix" do
      result = described_class.sha256("hello")
      expect(result).to start_with("0x")
      expect(result.length).to eq(66) # 0x + 64 hex chars
    end

    it "returns the known sha256 of 'hello'" do
      # sha256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
      result = described_class.sha256("hello")
      expect(result).to eq("0x2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    end

    it "produces different results than keccak256" do
      expect(described_class.sha256("data")).not_to eq(described_class.keccak256("data"))
    end
  end
end
