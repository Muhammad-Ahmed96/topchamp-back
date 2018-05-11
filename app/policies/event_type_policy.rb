class EventTypePolicy < ApplicationPolicy
  attr_reader :user, :event_type
  def index?
    user.sysadmin? || user.agent? || user.director?
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
