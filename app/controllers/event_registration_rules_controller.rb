class EventRegistrationRulesController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:create]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:create]

  swagger_path '/events/:id/registration_rule' do
    operation :put do
      key :summary, 'Events registration rule'
      key :description, 'Events Catalog'
      key :operationId, 'eventsRegistrationRule'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :registration_rule
        key :in, :body
        key :description, 'Registration rule'
        key :required, true
        schema do
          key :'$ref', :EventRegistrationRuleInput
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :Event
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def create
    authorize Event
    if registration_rule_params.present?
      registration_rule = @event.registration_rule
      if registration_rule.present?
        registration_rule.update! registration_rule_params
      else
        @event.create_registration_rule! registration_rule_params
      end
    end
    json_response_serializer(@event, EventSerializer)
  end

  private

  def registration_rule_params
    # whitelist params
    unless params[:registration_rule].nil?
      params.require(:registration_rule).permit(:allow_group_registrations, :partner, :require_password,
                                                :password, :require_director_approval, :allow_players_cancel, :use_link_home_page,
                                                :link_homepage, :use_link_event_website, :link_event_website, :use_app_event_website, :link_app,
                                                :allow_attendees_change, :allow_waiver, :waiver, :allow_wait_list, :is_share, :add_to_my_calendar,
                                                :enable_map, :share_my_cell_phone, :share_my_email, :player_cancel_start_date, :player_cancel_start_end)
    end
  end

  # search current resource of id
  def set_resource
    #apply policy scope
    @event = EventPolicy::Scope.new(current_user, Event).resolve.find(params[:event_id])
  end
end
