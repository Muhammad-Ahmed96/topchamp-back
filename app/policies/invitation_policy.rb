class InvitationPolicy < ApplicationPolicy
  attr_reader :user

  def index?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def update?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def create?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def event?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def date?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def sing_up?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end


  def show?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def destroy?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def import_xls?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def resend_mail?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  class Scope < Scope
    def resolve
      scope.joins(:event).merge(Event.where :creator_user_id => user.id)
    end
  end
end
