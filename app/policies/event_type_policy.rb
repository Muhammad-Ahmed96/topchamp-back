class EventTypePolicy < ApplicationPolicy
  attr_reader :user, :event_type
  def index?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def create?
    user.sysadmin?
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
