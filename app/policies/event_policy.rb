class EventPolicy < ApplicationPolicy
  attr_reader :user

  def index?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def update?
    user.sysadmin? || user.agent? || user.director?
  end

  def create?
    user.sysadmin? || user.agent? || user.director?
  end


  def show?
    user.sysadmin? || user.agent? || user.director? || user.member?
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

  def create_venue?
    user.sysadmin? || user.agent? || user.director?
  end

  def venue?
    user.sysadmin? || user.agent? || user.director?
  end

  def payment_information?
    user.sysadmin? || user.agent? || user.director?
  end

  def payment_method?
    user.sysadmin? || user.agent? || user.director?
  end

  def discounts?
    user.sysadmin? || user.agent? || user.director?
  end

  def import_discount_personalizeds?
    user.sysadmin? || user.agent? || user.director?
  end

  def tax?
    user.sysadmin? || user.agent? || user.director?
  end

  def refund_policy?
    user.sysadmin? || user.agent? || user.director?
  end

  def service_fee?
    user.sysadmin? || user.agent? || user.director?
  end

  def registration_rule?
    user.sysadmin? || user.agent? || user.director?
  end

  def details?
    user.sysadmin? || user.agent? || user.director?
  end

  def agendas?
    user.sysadmin? || user.agent? || user.director?
  end

  def coming_soon?
    true
  end

  def upcoming?
    true
  end

  def categories?
    true
  end
  class Scope < Scope
    def resolve
      if user.sysadmin? || user.agent?  || user.member?
        scope.all
      elsif user.director?
        scope.where(creator_user_id: user.id).or(scope.where(invited_director_id: user.id))
      else
        scope
      end
    end
  end
end
