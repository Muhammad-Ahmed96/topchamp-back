class ContactInformation < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user
  #validates :cell_phone, presence: true, numericality: { only_integer: true },  length: { is: 10 }

  swagger_schema :ContactInformation do
    key :required, [:id, :user_id, :cell_phone]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with contact information"
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id associated with contact information"
    end
    property :country_code_phone do
      key :type, :string
      key :description, "Country code phone associated with contact information"
    end
    property :cell_phone do
      key :type, :integer
      key :format, :int64
      key :description, "Cell phone associated with contact information"
    end
    property :alternative_email do
      key :type, :string
      key :description, "Alternative email associated with contact information"
    end
    property :address_line_1 do
      key :type, :string
      key :description, "Address line 1 associated with contact information"
    end
    property :address_line_2 do
      key :type, :string
      key :description, "Address line 2 associated with contact information"
    end
    property :postal_code do
      key :type, :string
      key :description, "Postal code associated with contact information"
    end
    property :state do
      key :type, :string
      key :description, "State associated with contact information"
    end
    property :city do
      key :type, :string
      key :description, "City associated with contact information"
    end
    property :country_code_work_phone do
      key :type, :string
      key :description, "Country code work phone associated with contact information"
    end
    property :work_phone do
      key :type, :integer
      key :format, :int64
      key :description, "Work phone associated with contact information"
    end
    property :emergency_contact_full_name do
      key :type, :string
      key :description, "Emergency contact full name associated with contact information"
    end
    property :emergency_contact_country_code_phone do
      key :type, :string
      key :description, "Emergency contact country code phone  associated with contact information"
    end
    property :emergency_contact_phone do
      key :type, :integer
      key :format, :int64
      key :description, "Emergency contact phone associated with contact information"
    end
    property :country do
      key :type, :string
      key :description, "Country associated with contact information"
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
    property :country do
      key :type, :string
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

  swagger_schema :ContactInformationInputSingUpContinue do
    key :required, [:postal_code, :state]
    property :postal_code do
      key :type, :string
    end
    property :state do
      key :type, :string
    end
    property :city do
      key :type, :string
    end
    property :country do
      key :type, :string
    end
  end
end
