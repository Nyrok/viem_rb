# frozen_string_literal: true

module Viem
  module Abi
    module Parse
      TYPE_REGEX = /^(function|event|error|constructor|fallback|receive)\s+/

      def self.parse_abi(signatures)
        signatures.map { |sig| parse_abi_item(sig) }
      end

      def self.parse_abi_item(sig)
        sig  = sig.strip
        kind = case sig
               when /^function /    then "function"
               when /^event /       then "event"
               when /^error /       then "error"
               when /^constructor/  then "constructor"
               else                      "function"
               end

        sig = sig.sub(TYPE_REGEX, "")
        name, rest = sig.split("(", 2)
        args_str, output_str = rest&.split(")")
        inputs  = parse_params(args_str || "")
        outputs = parse_outputs(output_str || "")

        item = { "type" => kind, "name" => name&.strip, "inputs" => inputs }
        item["outputs"]          = outputs if kind == "function"
        item["stateMutability"]  = detect_mutability(sig)
        item
      end

      private_class_method def self.parse_params(str)
        return [] if str.nil? || str.strip.empty?

        str.split(",").map.with_index do |p, i|
          parts = p.strip.split(/\s+/)
          { "type" => parts[0], "name" => parts[1] || "arg#{i}" }
        end
      end

      private_class_method def self.parse_outputs(str)
        return [] if str.nil? || str.strip.empty?

        cleaned = str.sub(/\s*returns?\s*\(/, "").sub(/\)\s*$/, "")
        parse_params(cleaned)
      end

      private_class_method def self.detect_mutability(sig)
        return "view"     if sig.include?("view")
        return "pure"     if sig.include?("pure")
        return "payable"  if sig.include?("payable")

        "nonpayable"
      end
    end
  end
end
