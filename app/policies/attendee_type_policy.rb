class AttendeeTypePolicy < ApplicationPolicy
  attr_reader :user
  def index?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def update?
    user.sysadmin?
  end

  def create?
    user.sysadmin?
  end


  def show?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def destroy?
    user.sysadmin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
