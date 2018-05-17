class AttendeeTypePolicy < ApplicationPolicy

  def index?
    user.sysadmin?
  end

  def update?
    user.sysadmin?
  end

  def create?
    user.sysadmin?
  end


  def show?
    user.sysadmin?
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
