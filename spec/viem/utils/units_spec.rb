# frozen_string_literal: true

RSpec.describe Viem::Utils::Units do
  describe ".parse_ether" do
    it "converts 1 ETH to wei" do
      expect(described_class.parse_ether("1")).to eq(1_000_000_000_000_000_000)
    end

    it "converts 0.5 ETH to wei" do
      expect(described_class.parse_ether("0.5")).to eq(500_000_000_000_000_000)
    end

    it "converts 0 ETH to 0 wei" do
      expect(described_class.parse_ether("0")).to eq(0)
    end

    it "handles large amounts" do
      expect(described_class.parse_ether("1000")).to eq(1_000_000_000_000_000_000_000)
    end
  end

  describe ".format_ether" do
    it "converts 1 ETH worth of wei to string" do
      result = described_class.format_ether(1_000_000_000_000_000_000)
      expect(result).to eq("1.0")
    end

    it "converts 0.5 ETH" do
      result = described_class.format_ether(500_000_000_000_000_000)
      expect(result).to eq("0.5")
    end

    it "converts 0 wei" do
      result = described_class.format_ether(0)
      expect(result).to eq("0.0")
    end
  end

  describe ".parse_gwei" do
    it "converts 1 Gwei to wei" do
      expect(described_class.parse_gwei("1")).to eq(1_000_000_000)
    end

    it "converts 1.5 Gwei to wei" do
      expect(described_class.parse_gwei("1.5")).to eq(1_500_000_000)
    end
  end

  describe ".format_gwei" do
    it "converts wei to Gwei string" do
      result = described_class.format_gwei(1_000_000_000)
      expect(result).to eq("1.0")
    end

    it "handles fractional Gwei" do
      result = described_class.format_gwei(1_500_000_000)
      expect(result).to eq("1.5")
    end
  end

  describe ".parse_units" do
    it "parses with 6 decimals (USDC)" do
      expect(described_class.parse_units("1", 6)).to eq(1_000_000)
    end

    it "parses with 18 decimals" do
      expect(described_class.parse_units("1", 18)).to eq(1_000_000_000_000_000_000)
    end
  end

  describe ".format_units" do
    it "formats with 6 decimals" do
      result = described_class.format_units(1_000_000, 6)
      expect(result).to eq("1.0")
    end

    it "formats with 18 decimals" do
      result = described_class.format_units(1_000_000_000_000_000_000, 18)
      expect(result).to eq("1.0")
    end
  end
end
