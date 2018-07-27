include AuthorizeNet::API
module Payments
  class CreditCard
    include Swagger::Blocks

    swagger_schema :CreditCard do
      property :cardNumber do
        key :type, :string
      end
      property :expirationDate do
        key :type, :string
      end
      property :cardType do
        key :type, :string
      end
      property :issuerNumber do
        key :type, :string
      end
      property :isPaymentToken do
        key :type, :boolean
      end
    end
  end
end