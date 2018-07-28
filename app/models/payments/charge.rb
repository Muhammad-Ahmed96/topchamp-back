include AuthorizeNet::API
module Payments
  class Charge
    def create
      transaction = Conexion.get
    end

    def self.customer(customerProfileId, customerPaymentProfileId, cardCode, amount, items, tax= nil)
      transaction = Conexion.get
      request = CreateTransactionRequest.new

      request.transactionRequest = TransactionRequestType.new()
      request.transactionRequest.amount = amount
      request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
      #request.transactionRequest.order = OrderType.new("invoiceNumber#{(SecureRandom.random_number * 1000000).round(0)}", "Order Description")
      request.transactionRequest.profile = CustomerProfilePaymentType.new
      request.transactionRequest.profile.customerProfileId = customerProfileId
      request.transactionRequest.profile.paymentProfile = AuthorizeNet::API::PaymentProfile.new(customerPaymentProfileId, cardCode)
      if items.kind_of?(Array)
        # Build an array of line items
        lineItemArr = Array.new
        items.each do |item|
          # Arguments for LineItemType.new are itemId, name, description, quanitity, unitPrice, taxable
          lineItem = LineItemType.new(item[:id], item[:name], item[:description], item[:quantity], item[:unit_price], item[:taxable])
          lineItemArr.push(lineItem)
        end
        request.transactionRequest.lineItems = LineItems.new(lineItemArr)
      end
      if tax.present?
        # Arguments for ExtendedAmountType.new are amount, name, description
        request.transactionRequest.tax = ExtendedAmountType.new(tax[:amount],tax[:name],tax[:description])
      end

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
            #raise "Failed to charge customer profile."
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
          #raise "Failed to charge customer profile."
        end
      else
        puts "Response is null"
        raise "Failed to charge customer profile."
      end

      return response
    end
  end
end