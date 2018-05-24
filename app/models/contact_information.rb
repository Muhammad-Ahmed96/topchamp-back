class ContactInformation < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user
  validates :cell_phone, presence: true, numericality: { only_integer: true },  length: { is: 10 }

  swagger_schema :ContactInformation do
    key :required, [:id, :user_id, :cell_phone]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
    end
    property :country_code_phone do
      key :type, :string
    end
    property :cell_phone do
      key :type, :integer
      key :format, :int64
    end
    property :alternative_email do
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
    property :state do
      key :type, :string
    end
    property :city do
      key :type, :string
    end
    property :country_code_work_phone do
      key :type, :string
    end
    property :work_phone do
      key :type, :integer
      key :format, :int64
    end
    property :emergency_contact_full_name do
      key :type, :string
    end
    property :emergency_contact_country_code_phone do
      key :type, :string
    end
    property :emergency_contact_phone do
      key :type, :integer
      key :format, :int64
    end
  end

  swagger_schema :ContactInformationInput do
    key :required, [:cell_phone]
     property :country_code_phone do
      key :type, :string
    end
    property :cell_phone do
      key :type, :integer
      key :format, :int64
    end
    property :alternative_email do
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
    property :state do
      key :type, :string
    end
    property :city do
      key :type, :string
    end
    property :country_code_work_phone do
      key :type, :string
    end
    property :work_phone do
      key :type, :integer
      key :format, :int64
    end
    property :emergency_contact_full_name do
      key :type, :string
    end
    property :emergency_contact_country_code_phone do
      key :type, :string
    end
    property :emergency_contact_phone do
      key :type, :integer
      key :format, :int64
    end
  end
  swagger_schema :ContactInformationInputSingUp do
    key :required, [:cell_phone, :country_code_phone]
    property :country_code_phone do
      key :type, :string
    end
    property :cell_phone do
      key :type, :integer
      key :format, :int64
    end
  end
end
