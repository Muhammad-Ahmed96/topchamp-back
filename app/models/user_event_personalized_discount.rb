class UserEventPersonalizedDiscount < ApplicationRecord
  acts_as_paranoid
  include Swagger::Blocks
  belongs_to :user

  swagger_schema :UserEventPersonalizedDiscount do
    property :id do
      key :type, :integer
      key :description, "Id associated with discount"
    end
    property :name do
      key :type, :string
      key :description, "Name associated with discount"
    end

    property :email do
      key :type, :string
      key :description, "Email associated with discount"
    end

    property :code do
      key :type, :string
      key :description, "Code associated with discount"
    end

    property :discount do
      key :type, :number
      key :format, :float
      key :description, "Discount associated with discount"
    end
  end

  swagger_schema :UserEventPersonalizedDiscountInput do

    property :id do
      key :type, :integer
      key :description, "Id associated with discount"
    end
    property :name do
      key :type, :string
      key :description, "Name associated with discount"
    end

    property :email do
      key :type, :string
      key :description, "Email associated with discount"
    end

    property :code do
      key :type, :string
      key :description, "Code associated with discount"
    end

    property :discount do
      key :type, :number
      key :format, :float
      key :description, "Discount associated with discount"
    end
  end
end
