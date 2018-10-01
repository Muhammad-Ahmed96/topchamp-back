class EventFee < ApplicationRecord
  acts_as_paranoid
  include Swagger::Blocks

  swagger_schema :EventFee do

    property :base_fee do
      key :type, :number
      key :format, :float
      key :description, "Base fee associated with user"
    end

    property :transaction_fee do
      key :type, :number
      key :format, :float
      key :description, "Transaction fee associated with user"
    end

  end

  swagger_schema :EventFeeInput do

    property :base_fee do
      key :type, :number
      key :format, :float
      key :description, "Base fee associated with user"
    end

    property :transaction_fee do
      key :type, :number
      key :format, :float
      key :description, "Transaction fee associated with user"
    end

  end
end
