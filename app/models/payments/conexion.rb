include AuthorizeNet::API
module Payments
  class Conexion
    def self.get
      transaction = Transaction.new( Rails.configuration.authorize[:api_login_id], Rails.configuration.authorize[:api_transaction_key],
                                     :gateway =>  Rails.configuration.authorize[:gateway])
      return transaction
    end
  end
end