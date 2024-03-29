class EventPaymentInformation < ApplicationRecord
  include Swagger::Blocks

  validates :service_fee, numericality: { less_than_or_equal_to: 100 }, :allow_nil => true
  swagger_schema :EventPaymentInformation do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with payment information"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :bank_name do
      key :type, :string
      key :description, "Bank name associated with payment information"
    end
    property :bank_account do
      key :type, :string
      key :description, "Bank account associated with payment information"
    end
    property :service_fee do
      key :type, :number
      key :format, :float
      key :description, "Service fee associated with payment information"
    end
    property :app_fee do
      key :type, :number
      key :format, :float
      key :description, "App fee associated with payment information"
    end
  end

  swagger_schema :EventPaymentInformationInput do
    property :bank_name do
      key :type, :string
    end
    property :bank_account do
      key :type, :string
    end
    property :service_fee do
      key :type, :number
      key :format, :float
    end
    property :refund_policy do
      key :type, :string
    end
    property :app_fee do
      key :type, :number
      key :format, :float
    end
  end


  swagger_schema :EventPaymentInformationServiceFee do
    property :service_fee do
      key :type, :number
      key :format, :float
    end
    property :app_fee do
      key :type, :number
      key :format, :float
    end
  end

  swagger_schema :EventPaymentInformationRefundPolicy do
    property :refund_policy do
      key :type, :string
    end
  end
end
