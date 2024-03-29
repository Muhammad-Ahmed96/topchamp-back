class MedicalInformation < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user
  validates :primary_physician_phone, presence: false

  swagger_schema :MedicalInformation do
    key :required, [:id, :user_id]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with medical information"
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id associated with medical information"
    end
    property :insurance_provider do
      key :type, :string
      key :description, "Insurance provider associated with medical information"
    end
    property :insurance_policy_number do
      key :type, :string
      key :description, "Insurance policy number associated with medical information"
    end
    property :group_id do
      key :type, :string
      key :description, "Group id associated with medical information"
    end
    property :primary_physician_full_name do
      key :type, :string
      key :description, "Primary physician full name associated with medical information"
    end
    property :primary_physician_country_code_phone do
      key :type, :string
      key :description, "Primary physician country code phone associated with medical information"
    end
    property :primary_physician_phone do
      key :type, :integer
      key :format, :int64
      key :description, "Primary physician phone associated with medical information"
    end
    property :dietary_restrictions do
      key :type, :string
      key :description, "Dietary restrictions associated with medical information"
    end
    property :allergies do
      key :type, :string
      key :description, "Allergies associated with medical information"
    end
  end

  swagger_schema :MedicalInformationInput do
    property :insurance_provider do
      key :type, :string
    end
    property :insurance_policy_number do
      key :type, :string
    end
    property :group_id do
      key :type, :string
    end
    property :primary_physician_full_name do
      key :type, :string
    end
    property :primary_physician_country_code_phone do
      key :type, :string
    end
    property :primary_physician_phone do
      key :type, :integer
      key :format, :int64
    end
    property :dietary_restrictions do
      key :type, :string
    end
    property :allergies do
      key :type, :string
    end
  end
end
