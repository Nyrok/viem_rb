# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

module Viem
  module Utils
    module Units
      WEI_PER_ETHER = 10**18
      WEI_PER_GWEI  = 10**9

      def self.parse_ether(ether)
        (BigDecimal(ether.to_s) * WEI_PER_ETHER).to_i
      end

      def self.format_ether(wei)
        (BigDecimal(wei.to_s) / WEI_PER_ETHER).to_s("F")
      end

      def self.parse_gwei(gwei)
        (BigDecimal(gwei.to_s) * WEI_PER_GWEI).to_i
      end

      def self.format_gwei(wei)
        (BigDecimal(wei.to_s) / WEI_PER_GWEI).to_s("F")
      end

      def self.parse_units(value, decimals)
        (BigDecimal(value.to_s) * (10**decimals)).to_i
      end

      def self.format_units(value, decimals)
        (BigDecimal(value.to_s) / (10**decimals)).to_s("F")
      end
    end
  end
end
