class EventPolicy < ApplicationPolicy
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


  def show?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def destroy?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def activate?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def inactive?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def create_venue?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def venue?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def payment_information?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def payment_method?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def discounts?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def import_discount_personalizeds?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def tax?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def refund_policy?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def service_fee?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def registration_rule?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def details?
    user.sysadmin? || user.agent? || user.director? || user.member?
  end

  def agendas?
    user.sysadmin? || user.agent? || user.director? || user.member?
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

  def user_cancel?
    record.registration_rule.allow_players_cancel
  end
  def change_attendees?
    record.registration_rule.allow_attendees_change
  end
  class Scope < Scope
    def resolve
      if user.sysadmin? || user.agent?
        scope.all
      elsif user.is_director
        scope.joins(participants: [:attendee_types]).merge(Participant.where :user_id => user.id).merge(AttendeeType.where :id => AttendeeType.director_id)
      else
        scope.joins(participants: [:attendee_types]).merge(Participant.where :user_id => user.id)
      end
    end
  end
end
