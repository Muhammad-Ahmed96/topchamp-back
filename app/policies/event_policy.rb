class EventPolicy < ApplicationPolicy
  attr_reader :user

  def index?
    user.sysadmin? || user.agent? || user.director?
  end

  def update?
    user.sysadmin? || user.agent? || user.director?
  end

  def create?
    user.sysadmin? || user.agent? || user.director?
  end


  def show?
    user.sysadmin? || user.agent? || user.director?
  end

  def destroy?
    user.sysadmin? || user.agent? || user.director?
  end

  def activate?
    user.sysadmin? || user.agent? || user.director?
  end

  def inactive?
    user.sysadmin? || user.agent? || user.director?
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
