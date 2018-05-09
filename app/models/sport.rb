class Sport < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  has_and_belongs_to_many :users
  validates :name, presence: false,  length: { maximum: 50 }

  swagger_schema :Sport do
    key :required, [:name]
    property :id do
      key :type, :string
    end

  end
end
