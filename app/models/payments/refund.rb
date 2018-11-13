include AuthorizeNet::API
require 'action_view'
include ActionView::Helpers::NumberHelper
module Payments
  class Refund
    def self.credit_card(amount, card_number, expiration_date)
      transaction = Conexion.get
      request = CreateTransactionRequest.new

      request.transactionRequest = TransactionRequestType.new()
      request.transactionRequest.amount = amount
      request.transactionRequest.payment = PaymentType.new
      request.transactionRequest.payment.creditCard = CreditCardType.new(card_number, expiration_date)
      #request.transactionRequest.refTransId = 2233511297
      request.transactionRequest.transactionType = TransactionTypeEnum::RefundTransaction

      response = transaction.create_transaction(request)

      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          if response.transactionResponse != nil && response.transactionResponse.messages != nil
            puts "Successfully refunded a transaction (Transaction ID #{response.transactionResponse.transId})"
            puts "Transaction Response code: #{response.transactionResponse.responseCode}"
            puts "Code: #{response.transactionResponse.messages.messages[0].code}"
            puts "Description: #{response.transactionResponse.messages.messages[0].description}"
          else
            puts "Transaction Failed"
            if response.transactionResponse.errors != nil
              puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
              puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
            end
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
        end
      else
        puts "Response is null"
      end

      return response
    end

    def self.bank_account(amount, routingNumber, accountNumber, nameOnAccount, bankName)
      transaction = Conexion.get
      request = CreateTransactionRequest.new

      request.transactionRequest = TransactionRequestType.new()
      request.transactionRequest.amount = amount
      request.transactionRequest.payment = PaymentType.new
      request.transactionRequest.payment.bankAccount = BankAccountType.new('checking', routingNumber, accountNumber, nameOnAccount, 'PPD', bankName)
      #request.transactionRequest.refTransId = 2233511297
      request.transactionRequest.transactionType = TransactionTypeEnum::RefundTransaction

      response = transaction.create_transaction(request)

      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          if response.transactionResponse != nil && response.transactionResponse.messages != nil
            puts "Successfully refunded a transaction (Transaction ID #{response.transactionResponse.transId})"
            puts "Transaction Response code: #{response.transactionResponse.responseCode}"
            puts "Code: #{response.transactionResponse.messages.messages[0].code}"
            puts "Description: #{response.transactionResponse.messages.messages[0].description}"
          else
            puts "Transaction Failed"
            if response.transactionResponse.errors != nil
              puts "Error Code: #{response.transactionResponse.errors.errors[0].errorCode}"
              puts "Error Message: #{response.transactionResponse.errors.errors[0].errorText}"
            end
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
        end
      else
        puts "Response is null"
      end

      return response
    end
  end
end