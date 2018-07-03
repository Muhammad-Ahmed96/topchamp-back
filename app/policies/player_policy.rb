class PlayerPolicy < ApplicationPolicy
  attr_reader :user
  def index?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def update?
    user.sysadmin? || user.agent?  || user.member?|| user.director? || user.id == record.id
  end

  def create?
    user.sysadmin? || user.agent?  || user.member? || user.director?
  end


  def show?
    user.sysadmin? || user.agent? || user.director? || user.member? || user.id == record.id
  end

  def destroy?
    user.sysadmin? || user.agent? || user.director? || user.member? || user.id == record.id
  end

  def activate?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def inactive?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
