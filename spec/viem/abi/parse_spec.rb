# frozen_string_literal: true

RSpec.describe Viem::Abi::Parse do
  describe ".parse_abi" do
    it "parses multiple signatures at once" do
      result = described_class.parse_abi([
        "function balanceOf(address account) view returns (uint256)",
        "event Transfer(address indexed from, address indexed to, uint256 value)"
      ])
      expect(result.length).to eq(2)
      expect(result[0]["type"]).to eq("function")
      expect(result[1]["type"]).to eq("event")
    end
  end

  describe ".parse_abi_item" do
    context "function signatures" do
      it "parses a view function" do
        item = described_class.parse_abi_item("function balanceOf(address account) view returns (uint256)")
        expect(item["type"]).to eq("function")
        expect(item["name"]).to eq("balanceOf")
        expect(item["stateMutability"]).to eq("view")
        expect(item["inputs"].first["type"]).to eq("address")
      end

      it "parses a pure function" do
        item = described_class.parse_abi_item("function add(uint256 a, uint256 b) pure returns (uint256)")
        expect(item["stateMutability"]).to eq("pure")
        expect(item["inputs"].length).to eq(2)
      end

      it "parses a payable function" do
        item = described_class.parse_abi_item("function deposit() payable")
        expect(item["stateMutability"]).to eq("payable")
        expect(item["inputs"]).to eq([])
      end

      it "parses a nonpayable function (default)" do
        item = described_class.parse_abi_item("function transfer(address to, uint256 amount)")
        expect(item["stateMutability"]).to eq("nonpayable")
        expect(item["inputs"].length).to eq(2)
        expect(item["inputs"][0]["type"]).to eq("address")
        expect(item["inputs"][1]["type"]).to eq("uint256")
      end

      it "parses a no-arg function" do
        item = described_class.parse_abi_item("function totalSupply() view returns (uint256)")
        expect(item["name"]).to eq("totalSupply")
        expect(item["inputs"]).to eq([])
      end
    end

    context "event signatures" do
      it "parses an event" do
        item = described_class.parse_abi_item("event Transfer(address indexed from, address indexed to, uint256 value)")
        expect(item["type"]).to eq("event")
        expect(item["name"]).to eq("Transfer")
        expect(item["inputs"].length).to eq(3)
      end
    end

    context "error signatures" do
      it "parses a custom error" do
        item = described_class.parse_abi_item("error InsufficientBalance(address account, uint256 balance)")
        expect(item["type"]).to eq("error")
        expect(item["name"]).to eq("InsufficientBalance")
        expect(item["inputs"].length).to eq(2)
      end
    end

    context "constructor signatures" do
      it "parses a constructor" do
        item = described_class.parse_abi_item("constructor(address owner, uint256 initialSupply)")
        expect(item["type"]).to eq("constructor")
        expect(item["inputs"].length).to eq(2)
      end
    end
  end
end
