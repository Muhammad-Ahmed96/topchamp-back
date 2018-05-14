class BillingAddress < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user

  swagger_schema :BillingAddress do
    key :required, [:id, :user_id]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
    end
    property :address_line_1 do
      key :type, :string
    end
    property :address_line_2 do
      key :type, :string
    end
    property :postal_code do
      key :type, :string
    end
    property :city do
      key :type, :string
    end
    property :state do
      key :type, :string
    end
  end

  swagger_schema :BillingAddressInput do
    property :address_line_1 do
      key :type, :string
    end
    property :address_line_2 do
      key :type, :string
    end
    property :postal_code do
      key :type, :string
    end
    property :city do
      key :type, :string
    end
    property :state do
      key :type, :string
    end
  end
end
