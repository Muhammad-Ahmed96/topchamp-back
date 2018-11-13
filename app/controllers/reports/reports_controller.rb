class Reports::ReportsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def account
    search = params[:event_name].strip unless params[:event_name].nil?
    column = params[:column].nil? ? 'event_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    items = Event.my_order(column, direction).where(:creator_user_id => user_id).joins(participants: [:attendee_types]).merge(Participant.where :user_id => user_id).merge(AttendeeType.where :id => AttendeeType.director_id)
                .title_like(search).select("events.id AS event_id, events.title AS event_name, 0 AS gross_income, "+
                                               "0 AS net_income,"+
                                               "0 AS withdrawals,"+
                                               " 0 AS balance")
                .group("events.id")
    json_response_serializer_collection items, AccountReportSerializer
  end

  private

  def user_id
    params.require('user_id')
    params.permit('user_id')
    params['user_id']
  end
end
