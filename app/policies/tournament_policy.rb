class TournamentPolicy < ApplicationPolicy
  attr_reader :user

  def index?
    user.sysadmin? || user.agent? || user.director? || user.member? || user.customer?
  end
  class Scope < Scope
    def resolve
      if user.sysadmin? || user.agent? || user.customer?
        scope
      elsif user.is_director
        scope.where(:event_id => user.my_events)
      else
        scope
      end
    end
  end
end
