class UserPolicy < ApplicationPolicy
  attr_reader :user

  def index?
    user.sysadmin? || user.agent?
  end

  def update?
    user.sysadmin? || user.agent?
  end

  def create?
    user.sysadmin? || user.agent?
  end


  def show?
    user.sysadmin? || user.agent?
  end

  def destroy?
    user.sysadmin? || user.agent?
  end

  def activate?
    user.sysadmin? || user.agent?
  end

  def inactive?
    user.sysadmin? || user.agent?
  end

  def profile?
    user.sysadmin? || user.agent?
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
