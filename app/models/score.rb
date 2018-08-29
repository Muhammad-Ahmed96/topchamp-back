class Score < ApplicationRecord
  include Swagger::Blocks
  attr_accessor :de
  belongs_to :set, :class_name => "MatchSet", foreign_key: "match_set_id"
  belongs_to :team


  swagger_schema :ScoreInput do
    property :number_set do
      key :type, :integer
      key :format, :int64
      key :description, "Number set associated with score"
    end

    property :score do
      key :type, :integer
      key :format, :int64
      key :description, "Score associated with score"
    end


    property :time_out do
      key :type, :integer
      key :format, :int64
      key :description, "Time out associated with score"
    end
  end
end
