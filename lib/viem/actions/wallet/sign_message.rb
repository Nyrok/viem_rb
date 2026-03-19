# frozen_string_literal: true

module Viem
  module Actions
    module Wallet
      module SignMessage
        def sign_message(message:, account: nil)
          acct = account || @account
          raise AccountRequiredError unless acct

          acct.sign_message(message)
        end
      end
    end
  end
end
