class ShippingAddress < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user

  swagger_schema :ShippingAddress do
    key :required, [:id, :user_id]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
    end
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
