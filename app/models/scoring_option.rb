class ScoringOption < ApplicationRecord
  include Swagger::Blocks
  swagger_schema :ScoringOption do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :description do
      key :type, :string
    end
  end

  swagger_schema :ScoringOptionInput do
    property :description do
      key :type, :string
    end
    property :quantity_games do
      key :type, :int64
    end
    property :winner_games do
      key :type, :int64
    end
    property :points do
      key :type, :float
    end
    property :duration do
      key :type, :float
    end
  end
end
