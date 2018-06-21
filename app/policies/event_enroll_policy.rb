class EventEnrollPolicy < ApplicationPolicy
  attr_reader :user
  def user_cancel?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
