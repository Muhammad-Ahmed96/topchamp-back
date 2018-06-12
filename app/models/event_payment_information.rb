class EventPaymentInformation < ApplicationRecord
  include Swagger::Blocks

  validates :service_fee, numericality: { less_than_or_equal_to: 100 }, :allow_nil => true
  swagger_schema :EventPaymentInformation do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :bank_name do
      key :type, :string
    end
    property :bank_account do
      key :type, :string
    end
  end

  swagger_schema :EventPaymentInformationInput do
    property :bank_name do
      key :type, :string
    end
    property :bank_account do
      key :type, :string
    end
  end
end