class BusinessCategory < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  scope :search, lambda{ |search| where ["LOWER(description) LIKE LOWER(?) OR LOWER(code) LIKE LOWER(?) OR  LOWER('group') LIKE LOWER(?)", "%#{search}%", "%#{search}%" , "%#{search}%"] if search.present? }
  scope :description_like, lambda{ |search| where ["LOWER(description)", "%#{search}%"] if search.present? }
  scope :code_like, lambda{ |search| where ["LOWER(code)", "%#{search}%"] if search.present? }
  scope :group_like, lambda{ |search| where ["LOWER('group')", "%#{search}%"] if search.present? }

  swagger_schema :BusinessCategory do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with business category"
    end
    property :description do
      key :type, :string
      key :description, "Description associated with business category"
    end
    property :code do
      key :type, :string
      key :description, "Code associated with business category"
    end
    property :group do
      key :type, :string
      key :description, "Group associated with business category"
    end
  end

end
