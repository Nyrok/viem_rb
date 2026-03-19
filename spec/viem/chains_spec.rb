# frozen_string_literal: true

RSpec.describe "Viem chain definitions" do
  describe "Viem::MAINNET" do
    subject { Viem::MAINNET }

    it { expect(subject.id).to eq(1) }
    it { expect(subject.name).to eq("Ethereum") }
    it { expect(subject.testnet?).to be false }
    it { expect(subject.rpc_url).to start_with("https://") }
    it { expect(subject.native_currency.symbol).to eq("ETH") }
    it { expect(subject.native_currency.decimals).to eq(18) }
  end

  describe "Viem::SEPOLIA" do
    subject { Viem::SEPOLIA }

    it { expect(subject.id).to eq(11_155_111) }
    it { expect(subject.testnet?).to be true }
    it { expect(subject.native_currency.symbol).to eq("ETH") }
  end

  describe "Viem::POLYGON" do
    subject { Viem::POLYGON }

    it { expect(subject.id).to eq(137) }
    it { expect(subject.testnet?).to be false }
    it { expect(subject.native_currency.symbol).to eq("MATIC") }
  end

  describe "Viem::POLYGON_MUMBAI" do
    subject { Viem::POLYGON_MUMBAI }

    it { expect(subject.id).to eq(80_001) }
    it { expect(subject.testnet?).to be true }
  end

  describe "Viem::OPTIMISM" do
    subject { Viem::OPTIMISM }

    it { expect(subject.id).to eq(10) }
    it { expect(subject.testnet?).to be false }
  end

  describe "Viem::ARBITRUM" do
    subject { Viem::ARBITRUM }

    it { expect(subject.id).to eq(42_161) }
    it { expect(subject.testnet?).to be false }
  end

  describe "Viem::BASE" do
    subject { Viem::BASE }

    it { expect(subject.id).to eq(8453) }
    it { expect(subject.testnet?).to be false }
  end

  describe "Viem::AVALANCHE" do
    subject { Viem::AVALANCHE }

    it { expect(subject.id).to eq(43_114) }
    it { expect(subject.native_currency.symbol).to eq("AVAX") }
    it { expect(subject.testnet?).to be false }
  end

  describe "Viem::BSC" do
    subject { Viem::BSC }

    it { expect(subject.id).to eq(56) }
    it { expect(subject.native_currency.symbol).to eq("BNB") }
    it { expect(subject.testnet?).to be false }
  end

  describe "Viem::GNOSIS" do
    subject { Viem::GNOSIS }

    it { expect(subject.id).to eq(100) }
    it { expect(subject.native_currency.symbol).to eq("xDAI") }
  end

  describe "Viem::CELO" do
    subject { Viem::CELO }

    it { expect(subject.id).to eq(42_220) }
    it { expect(subject.testnet?).to be false }
  end

  describe "all testnets" do
    let(:testnets) { [Viem::SEPOLIA, Viem::GOERLI, Viem::POLYGON_MUMBAI, Viem::OPTIMISM_GOERLI, Viem::ARBITRUM_GOERLI, Viem::BASE_GOERLI, Viem::AVALANCHE_FUJI, Viem::BSC_TESTNET] }

    it "all have testnet? == true" do
      testnets.each { |chain| expect(chain.testnet?).to be true }
    end
  end

  describe "all mainnets" do
    let(:mainnets) { [Viem::MAINNET, Viem::POLYGON, Viem::OPTIMISM, Viem::ARBITRUM, Viem::BASE, Viem::AVALANCHE, Viem::BSC, Viem::GNOSIS, Viem::FANTOM, Viem::CELO] }

    it "all have testnet? == false" do
      mainnets.each { |chain| expect(chain.testnet?).to be false }
    end
  end

  describe "chain IDs are unique" do
    let(:all_chains) do
      [
        Viem::MAINNET, Viem::SEPOLIA, Viem::GOERLI,
        Viem::POLYGON, Viem::POLYGON_MUMBAI,
        Viem::OPTIMISM, Viem::OPTIMISM_GOERLI,
        Viem::ARBITRUM, Viem::ARBITRUM_GOERLI,
        Viem::BASE, Viem::BASE_GOERLI,
        Viem::AVALANCHE, Viem::AVALANCHE_FUJI,
        Viem::BSC, Viem::BSC_TESTNET,
        Viem::GNOSIS, Viem::FANTOM, Viem::CELO
      ]
    end

    it "has no duplicate chain IDs" do
      ids = all_chains.map(&:id)
      expect(ids.uniq.length).to eq(ids.length)
    end
  end
end
