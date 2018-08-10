class BillingAddress < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user

  swagger_schema :BillingAddress do
    key :required, [:id, :user_id]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with billing address"
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id associated with billing address"
    end
    property :address_line_1 do
      key :type, :string
      key :description, "Address line 1 associated with billing address"
    end
    property :address_line_2 do
      key :type, :string
      key :description, "Address line 2 associated with billing address"
    end
    property :postal_code do
      key :type, :string
      key :description, "Postal code associated with billing address"
    end
    property :city do
      key :type, :string
      key :description, "City associated with billing address"
    end
    property :state do
      key :type, :string
      key :description, "State associated with billing address"
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
