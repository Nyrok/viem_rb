# frozen_string_literal: true

RSpec.describe Viem::Utils::Hex do
  describe ".is_hex?" do
    it "returns true for a valid hex string" do
      expect(described_class.is_hex?("0xdeadbeef")).to be true
    end

    it "returns true for 0x (empty hex)" do
      expect(described_class.is_hex?("0x")).to be true
    end

    it "returns false for strict mode with 0x empty" do
      expect(described_class.is_hex?("0x", strict: true)).to be false
    end

    it "returns true for strict mode with content" do
      expect(described_class.is_hex?("0xabc123", strict: true)).to be true
    end

    it "returns false for non-hex string" do
      expect(described_class.is_hex?("hello")).to be false
    end

    it "returns false for nil" do
      expect(described_class.is_hex?(nil)).to be false
    end

    it "returns false for integers" do
      expect(described_class.is_hex?(42)).to be false
    end
  end

  describe ".to_hex" do
    it "converts an integer to hex" do
      expect(described_class.to_hex(255)).to eq("0xff")
    end

    it "converts zero to hex" do
      expect(described_class.to_hex(0)).to eq("0x0")
    end

    it "converts a string to hex" do
      expect(described_class.to_hex("A")).to eq("0x41")
    end

    it "converts a byte array to hex" do
      expect(described_class.to_hex([0xde, 0xad])).to eq("0xdead")
    end

    it "pads to a given size" do
      expect(described_class.to_hex(1, size: 4)).to eq("0x#{("1".rjust(8, "0"))}")
    end

    it "raises for unsupported type" do
      expect { described_class.to_hex(Object.new) }.to raise_error(ArgumentError)
    end
  end

  describe ".hex_to_number" do
    it "converts hex string to integer" do
      expect(described_class.hex_to_number("0xff")).to eq(255)
    end

    it "handles large hex numbers" do
      expect(described_class.hex_to_number("0xde0b6b3a7640000")).to eq(1_000_000_000_000_000_000)
    end

    it "handles 0x0" do
      expect(described_class.hex_to_number("0x0")).to eq(0)
    end
  end

  describe ".number_to_hex" do
    it "converts integer to hex" do
      expect(described_class.number_to_hex(256)).to eq("0x100")
    end

    it "converts with size padding" do
      expect(described_class.number_to_hex(1, size: 2)).to eq("0x0001")
    end
  end

  describe ".hex_to_bytes" do
    it "converts hex to byte array" do
      expect(described_class.hex_to_bytes("0xdead")).to eq([0xde, 0xad])
    end
  end

  describe ".bytes_to_hex" do
    it "converts byte array to hex" do
      expect(described_class.bytes_to_hex([0xde, 0xad])).to eq("0xdead")
    end
  end

  describe ".hex_to_string" do
    it "decodes a hex string to UTF-8 string" do
      expect(described_class.hex_to_string("0x48656c6c6f")).to eq("Hello")
    end
  end

  describe ".string_to_hex" do
    it "encodes a string to hex" do
      expect(described_class.string_to_hex("Hello")).to eq("0x48656c6c6f")
    end
  end

  describe ".strip" do
    it "removes the 0x prefix" do
      expect(described_class.strip("0xabc")).to eq("abc")
    end

    it "leaves strings without prefix unchanged" do
      expect(described_class.strip("abc")).to eq("abc")
    end
  end
end
