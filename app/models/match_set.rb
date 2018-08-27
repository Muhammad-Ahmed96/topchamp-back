class MatchSet < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  belongs_to :match
  has_many :scores
end
