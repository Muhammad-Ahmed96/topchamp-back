class ShippingAddress < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user

  swagger_schema :ShippingAddress do
    key :required, [:id, :user_id]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with shipping address"
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id associated with shipping address"
    end
    property :contact_name do
      key :type, :string
      key :description, "Contact name associated with shipping address"
    end
    property :address_line_1 do
      key :type, :string
      key :description, "Address line 1 associated with shipping address"
    end
    property :address_line_2 do
      key :type, :string
      key :description, "Address line 2 associated with shipping address"
    end
    property :postal_code do
      key :type, :string
      key :description, "Postal code associated with shipping address"
    end
    property :city do
      key :type, :string
      key :description, "City associated with shipping address"
    end
    property :state do
      key :type, :string
      key :description, "State associated with shipping address"
    end
  end

  swagger_schema :ShippingAddressInput do
    property :contact_name do
      key :type, :string
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
end
