# frozen_string_literal: true

module Viem
  module Actions
    module Public
      module Ens
        ENS_REGISTRY = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"

        ENS_PUBLIC_RESOLVER_ABI = [
          {
            "name"            => "addr",
            "type"            => "function",
            "inputs"          => [{ "type" => "bytes32", "name" => "node" }],
            "outputs"         => [{ "type" => "address", "name" => "" }],
            "stateMutability" => "view"
          },
          {
            "name"            => "name",
            "type"            => "function",
            "inputs"          => [{ "type" => "bytes32", "name" => "node" }],
            "outputs"         => [{ "type" => "string",  "name" => "" }],
            "stateMutability" => "view"
          }
        ].freeze

        REGISTRY_ABI = [
          {
            "name"            => "resolver",
            "type"            => "function",
            "inputs"          => [{ "type" => "bytes32", "name" => "node" }],
            "outputs"         => [{ "type" => "address", "name" => "" }],
            "stateMutability" => "view"
          }
        ].freeze

        def get_ens_address(name:)
          node          = namehash(name)
          resolver_addr = read_contract(
            address: ENS_REGISTRY, abi: REGISTRY_ABI,
            function_name: "resolver", args: [node]
          )
          return nil if Utils::Address.is_zero_address?(resolver_addr)

          read_contract(
            address: resolver_addr, abi: ENS_PUBLIC_RESOLVER_ABI,
            function_name: "addr", args: [node]
          )
        rescue StandardError => e
          raise Error, "ENS resolution failed for #{name}: #{e.message}"
        end

        def get_ens_name(address:)
          address  = Utils::Address.get_address(address)
          reversed = "#{address.downcase.delete_prefix("0x")}.addr.reverse"
          node     = namehash(reversed)
          resolver_addr = read_contract(
            address: ENS_REGISTRY, abi: REGISTRY_ABI,
            function_name: "resolver", args: [node]
          )
          return nil if Utils::Address.is_zero_address?(resolver_addr)

          read_contract(
            address: resolver_addr, abi: ENS_PUBLIC_RESOLVER_ABI,
            function_name: "name", args: [node]
          )
        rescue StandardError
          nil
        end

        private

        def namehash(name)
          node = "\x00" * 32
          return Eth::Util.keccak256(node) if name.empty?

          name.split(".").reverse.each do |label|
            label_hash = Eth::Util.keccak256(label)
            node       = Eth::Util.keccak256(node + label_hash)
          end
          node
        end
      end
    end
  end
end
