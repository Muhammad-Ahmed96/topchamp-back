class Round < ApplicationRecord
  include Swagger::Blocks
  belongs_to :tournament
  has_many :matches, -> {order_by_index}, :dependent => :destroy

  attr_accessor :for_team_id


  scope :order_by_index,-> { order(index: :asc) }

  swagger_schema :Round do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with round"
    end
    property :index do
      key :type, :integer
      key :format, :int64
      key :description, "Index associated with round"
    end

    property :status do
      key :type, :string
      key :description, "Statusassociated with round"
    end

    property :matches do
      key :type, :array
      items do
        key :'$ref', :Match
      end
      key :description, "Matches associated with round"
    end
  end

  swagger_schema :RoundInput do
    property :index do
      key :type, :integer
      key :format, :int64
      key :description, "Index associated with round"
    end

    property :matches do
      key :type, :array
      items do
        key :'$ref', :MatchInput
      end
      key :description, "Matches associated with round"
    end
  end
end
