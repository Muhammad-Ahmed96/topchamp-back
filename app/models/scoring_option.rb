class ScoringOption < ApplicationRecord
  include Swagger::Blocks
  swagger_schema :ScoringOption do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with scoring option"
    end
    property :description do
      key :type, :string
      key :description, "description associated with scoring option"
    end
    property :quantity_games do
      key :type, :integer
      key :format, :int64
      key :description, "Quantity games associated with scoring option"
    end
    property :winner_games do
      key :type, :integer
      key :format, :int64
      key :description, "Winner games associated with scoring option"
    end
    property :points do
      key :type, :number
      key :format, :float
      key :description, "Points associated with scoring option"
    end
    property :duration do
      key :type, :number
      key :format, :float
      key :description, "Duration associated with scoring option"
    end
    property :win_by do
      key :type, :number
      key :format, :float
      key :description, "Win by associated with scoring option"
    end
  end

  swagger_schema :ScoringOptionInput do
    property :description do
      key :type, :string
    end
    property :quantity_games do
      key :type, :integer
      key :format, :int64
    end
    property :winner_games do
      key :type, :integer
      key :format, :int64
    end
    property :points do
      key :type, :number
      key :format, :float
    end
    property :duration do
      key :type, :number
      key :format, :float
    end
  end
end
