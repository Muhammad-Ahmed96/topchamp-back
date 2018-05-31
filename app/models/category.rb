class Category < ApplicationRecord
  include Swagger::Blocks

  swagger_schema :Category do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
  end

  swagger_schema :CategoryInput do
    key :required, [:name]
    property :name do
      key :type, :string
    end
  end
end
