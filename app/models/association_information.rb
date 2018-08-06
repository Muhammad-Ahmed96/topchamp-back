class AssociationInformation < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user
  swagger_schema :AssociationInformation do
    key :required, [:id, :user_id]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with association information"
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id associated with association information"
    end
    property :membership_type do
      key :type, :string
      key :description, "Membership type associated with association information"
    end
    property :membership_id do
      key :type, :string
      key :description, "Membership id associated with association information"
    end
    property :raking do
      key :type, :string
      key :description, "Raking associated with association information"
    end
    property :affiliation do
      key :type, :string
      key :description, "Affiliation associated with association information"
    end
    property :certification do
      key :type, :string
      key :description, "Certification associated with association information"
    end
    property :company do
      key :type, :string
      key :description, "Company associated with association information"
    end
  end

  swagger_schema :AssociationInformationInput do
    property :membership_type do
      key :type, :string
    end
    property :membership_id do
      key :type, :string
    end
    property :raking do
      key :type, :string
    end
    property :affiliation do
      key :type, :string
    end
    property :certification do
      key :type, :string
    end
    property :company do
      key :type, :string
    end
  end
end
