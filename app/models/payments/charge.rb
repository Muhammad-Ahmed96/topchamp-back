include AuthorizeNet::API
require 'action_view'
include ActionView::Helpers::NumberHelper
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
      request.transactionRequest.transactionType = TransactionTypeEnum::AuthOnlyTransaction
      #request.transactionRequest.order = OrderType.new("invoiceNumber#{(SecureRandom.random_number * 1000000).round(0)}", "Order Description")
      request.transactionRequest.profile = CustomerProfilePaymentType.new
      request.transactionRequest.profile.customerProfileId = customerProfileId
      request.transactionRequest.profile.paymentProfile = AuthorizeNet::API::PaymentProfile.new(customerPaymentProfileId, cardCode)
      #request.validationMode = ValidationModeEnum::LiveMode
      if items.kind_of?(Array)
        # Build an array of line items
        lineItemArr = Array.new
        items.each do |item|
          # Arguments for LineItemType.new are itemId, name, description, quanitity, unitPrice, taxable
          lineItem = LineItemType.new(item[:id], item[:name], item[:description], item[:quantity],number_with_precision(item[:unit_price], precision: 2), item[:taxable])
          lineItemArr.push(lineItem)
        end
        request.transactionRequest.lineItems = LineItems.new(lineItemArr)
      end
      if tax.present?
        # Arguments for ExtendedAmountType.new are amount, name, description
        request.transactionRequest.tax = ExtendedAmountType.new(number_with_precision(tax[:amount], precision: 2),tax[:name],tax[:description])
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

    def self.get_message(code, message = "")
      my_message = ""
      case code
      when "N"
        my_message = "CVV Does NOT Match"
      when "P"
        my_message = "CVV Is NOT Processed"
      when "S"
        my_message = "CVV Should be on card, but is not indicated"
      when "U"
        my_message = "CVV Issuer is not certified or has not provided encryption key"
      else
        my_message = message
      end
      my_message
    end
  end
end