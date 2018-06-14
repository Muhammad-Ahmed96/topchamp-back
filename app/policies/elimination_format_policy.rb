class EliminationFormatPolicy < ApplicationPolicy
  attr_reader :user
  def index?
    true
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
