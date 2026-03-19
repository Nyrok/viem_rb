# frozen_string_literal: true

module Viem
  class Error < StandardError; end

  class TransportError < Error; end

  class HttpRequestError < TransportError
    attr_reader :status, :body

    def initialize(msg = nil, status: nil, body: nil)
      @status = status
      @body   = body
      super(msg)
    end
  end

  class RpcError < Error
    attr_reader :code, :data

    def initialize(msg = nil, code: nil, data: nil)
      @code = code
      @data = data
      super(msg)
    end
  end

  class UserRejectedError < RpcError; end

  class ContractFunctionExecutionError < Error
    attr_reader :cause, :contract_address, :function_name, :args

    def initialize(cause, contract_address: nil, function_name: nil, args: [])
      @cause            = cause
      @contract_address = contract_address
      @function_name    = function_name
      @args             = args
      super("Contract function '#{function_name}' reverted: #{cause.message}")
    end
  end

  class AbiEncodingError < Error; end
  class AbiDecodingError < Error; end

  class InvalidAddressError < Error
    def initialize(address)
      super("Invalid Ethereum address: #{address.inspect}")
    end
  end

  class ChainMismatchError < Error; end

  class AccountRequiredError < Error
    def initialize
      super("No account set on WalletClient. Pass an account to the client or action.")
    end
  end

  class BlockNotFoundError < Error; end
  class TransactionNotFoundError < Error; end
  class TransactionReceiptNotFoundError < Error; end
  class WaitForTransactionReceiptTimeoutError < Error; end
end
