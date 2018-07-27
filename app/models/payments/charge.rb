module Payments
  class Charge
    def create
      transaction = Conexion.get
    end

    def customer(customerProfileId, customerPaymentProfileId, amount)
      transaction = Conexion.get
      request = CreateTransactionRequest.new

      request.transactionRequest = TransactionRequestType.new()
      request.transactionRequest.amount = amount
      request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
      request.transactionRequest.order = OrderType.new("invoiceNumber#{(SecureRandom.random_number * 1000000).round(0)}", "Order Description")
      request.transactionRequest.profile = CustomerProfilePaymentType.new
      request.transactionRequest.profile.customerProfileId = customerProfileId
      request.transactionRequest.profile.paymentProfile = PaymentProfile.new(customerPaymentProfileId)

      response = transaction.create_transaction(request)

      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          if response.transactionResponse != nil && response.transactionResponse.messages != nil
            puts "Success, Auth Code: #{response.transactionResponse.authCode}"
            puts "Transaction Response code: #{response.transactionResponse.responseCode}"
            puts "Code: #{response.transactionResponse.messages.messages[0].code}"
            puts "Description: #{response.transactionResponse.messages.messages[0].description}"
          else
            puts "Transaction Failed"
            if response.transactionResponse.errors != nil
              puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
              puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
            end
            raise "Failed to charge customer profile."
          end
        else
          puts "Transaction Failed"
          if response.transactionResponse != nil && response.transactionResponse.errors != nil
            puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
            puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
          else
            puts "Error Code: #{response.messages.messages[0].code}"
            puts "Error Message: #{response.messages.messages[0].text}"
          end
          raise "Failed to charge customer profile."
        end
      else
        puts "Response is null"
        raise "Failed to charge customer profile."
      end

      return response
    end
  end
end