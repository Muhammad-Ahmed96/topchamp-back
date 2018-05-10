class AssociationInformation < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user
  swagger_schema :AssociationInformation do
    key :required, [:id, :user_id]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
    end
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
