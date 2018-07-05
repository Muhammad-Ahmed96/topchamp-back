class Participant < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  before_create :set_status
  belongs_to :user
  belongs_to :event
  has_and_belongs_to_many :attendee_types

  private
  def set_status
    self.status = :Active
  end
end
