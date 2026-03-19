# frozen_string_literal: true

module Viem
  module Actions
    module Wallet
      module SignTypedData
        def sign_typed_data(domain:, types:, primary_type:, message:, account: nil)
          acct = account || @account
          raise AccountRequiredError unless acct

          acct.sign_typed_data(domain, types, message)
        end
      end
    end
  end
end
