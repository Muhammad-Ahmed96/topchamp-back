class InvitationPolicy < ApplicationPolicy
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

  def event?
    user.sysadmin? || user.agent? || user.director?
  end

  def date?
    user.sysadmin? || user.agent? || user.director?
  end

  def sing_up?
    user.sysadmin? || user.agent? || user.director?
  end


  def show?
    user.sysadmin? || user.agent? || user.director?
  end

  def destroy?
    user.sysadmin? || user.agent? || user.director?
  end

  def import_xls?
    user.sysadmin? || user.agent? || user.director?
  end

  def resend_mail?
    user.sysadmin? || user.agent? || user.director?
  end

  class Scope < Scope
    def resolve
      scope.where(sender_id: user.id)
    end
  end
end
