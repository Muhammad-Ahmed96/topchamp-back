class UserEventFee < ApplicationRecord
  acts_as_paranoid
  include Swagger::Blocks
  belongs_to :user

  swagger_schema :UserEventFee do

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

  swagger_schema :UserEventFeeInput do

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
