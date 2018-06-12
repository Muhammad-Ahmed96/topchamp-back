class LanguagePolicy < ApplicationPolicy
  attr_reader :user
  def index?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def update?
    user.sysadmin? || user.agent?
  end

  def create?
    user.sysadmin? || user.agent?
  end


  def show?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def destroy?
    user.sysadmin? || user.agent?
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
