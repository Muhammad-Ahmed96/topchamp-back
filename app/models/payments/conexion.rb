include AuthorizeNet::API
module Payments
  class Conexion
    def self.get
      authorize_config = YAML.load_file("#{Rails.root}/config/authorize_config.yml")
      transaction = Transaction.new(authorize_config['api_login_id'], authorize_config['api_transaction_key'], :gateway => :sandbox)
      return transaction
    end
  end
end