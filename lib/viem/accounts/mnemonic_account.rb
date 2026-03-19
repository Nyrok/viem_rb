# frozen_string_literal: true

require "eth"

module Viem
  module Accounts
    class MnemonicAccount < PrivateKeyAccount
      attr_reader :mnemonic, :path

      def initialize(mnemonic, path: "m/44'/60'/0'/0/0")
        @mnemonic = mnemonic
        @path     = path
        private_key = derive_private_key(mnemonic, path)
        super(private_key)
      end

      private

      def derive_private_key(mnemonic, path)
        # eth gem >= 0.5.10 supports HD wallets via Eth::Key::HD
        if defined?(Eth::Key::HD)
          seed   = Eth::Key::HD.mnemonic_to_seed(mnemonic)
          master = Eth::Key::HD.from_seed(seed)
          child  = master.derive(path)
          child.private_hex
        else
          raise NotImplementedError,
                "Mnemonic accounts require eth gem >= 0.5.10 with HD wallet support. " \
                "Use Viem.private_key_to_account instead."
        end
      end
    end
  end
end
