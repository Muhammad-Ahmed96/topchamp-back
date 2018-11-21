class Reports::EventsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def participant_payment
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    items = AttendeeType.joins(participants: [:event]).joins( "LEFT JOIN payment_transactions ON payment_transactions.attendee_type_id = attendee_types.id AND payment_transactions.event_id = #{event_id}").merge(Event.where(:id => event_id)).my_order(column, direction)
                .search(search).select("attendee_types.id, attendee_types.name, COUNT(participants.*) AS atttendees_number, COALESCE(SUM(payment_transactions.amount), 0) AS subtotal_charges")
                .group('attendee_types.id')
    json_response_data items
  end

  def registration_status
    column = params[:column].nil? ? 'participant' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    search_attendee_type = params[:search_attendee_type].strip unless params[:search_attendee_type].nil?
    search_participant = params[:search_participant].strip unless params[:search_participant].nil?
    status = params[:status]
    invitations = Invitation.joins(:user, :attendee_types).where(:event_id => event_id)
                    .in_status(status).my_order(column, direction).select("invitations.id AS invitation_id,users.id AS user_id, concat(users.first_name, users.last_name) AS participant, invitations.status AS status,"+
                      "(SELECT string_agg(DISTINCT attendee_types2.name,',') FROM attendee_types AS attendee_types2 "+
                                                                              "INNER JOIN attendee_types_invitations AS attendee_types_invitations2 ON attendee_types_invitations2.attendee_type_id = attendee_types2.id WHERE attendee_types_invitations2.invitation_id = invitations.id) AS attendee_types_names")
                      .group("invitations.id", "users.id")
    unless search_attendee_type.nil?
      invitations = invitations.where("LOWER(attendee_types.name) LIKE LOWER(?)", "%#{search_attendee_type}%")
    end
    unless search_participant.nil?
      invitations =  invitations.where("LOWER(participant) LIKE LOWER(?)", "%#{search_participant}%")
    end
    json_response_serializer_collection invitations, InvitationReportSerializer
  end

  def agenda_registration
    column = params[:column].nil? ? 'agenda_type_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    search_title = params[:search_title].strip unless params[:search_title].nil?
    search_type = params[:search_type].strip unless params[:search_type].nil?
    items = EventSchedule.my_order(column, direction).where(:event_id => event_id).joins(:agenda_type, 'INNER JOIN event_schedules_players ON event_schedules_players.event_schedule_id = event_schedules.id')
                .select("event_schedules.id AS event_schedule_id, event_schedules.title AS event_schedule_title, agenda_types.name AS agenda_type_name,"+
                                                                                  "COALESCE(event_schedules.capacity, 0) AS event_schedule_capacity, COUNT(event_schedules_players.event_schedule_id) AS number_registrant," +
                        "CASE WHEN event_schedules.capacity <= 0 THEN 100 WHEN event_schedules.capacity ISNULL THEN 100 ELSE COUNT(event_schedules_players.event_schedule_id) / event_schedules.capacity *  100 END  AS capacity_registrations")
    .group('event_schedules.id', 'agenda_types.name')
    unless search_title.nil?
      items = items.where("LOWER(event_schedules.title) LIKE LOWER(?)", "%#{search_title}%")
    end
    unless search_type.nil?
      items =  items.where("LOWER(agenda_types.name) LIKE LOWER(?)", "%#{search_type}%")
    end
    json_response_serializer_collection  items, EventScheduleReportSerializer
  end

  private

  def event_id
    params.require('event_id')
    params.permit('event_id')
    params['event_id']
  end
end
