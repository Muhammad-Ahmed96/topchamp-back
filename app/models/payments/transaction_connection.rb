include AuthorizeNet::API
require 'action_view'
include ActionView::Helpers::NumberHelper

module Payments
  class TransactionConnection
    def self.get_details(trans_id)
      transaction = Conexion.get
      request = GetTransactionDetailsRequest.new
      transId = trans_id
      request.transId = transId
      #standard api call to retrieve response
      response = transaction.get_transaction_details(request)
      if response.messages.resultCode == MessageTypeEnum::Ok

      else
       # puts response.messages.messages[0].code
       # puts response.messages.messages[0].text
        raise "Failed to get transaction Details."
      end

      return response
    end
  end
end
