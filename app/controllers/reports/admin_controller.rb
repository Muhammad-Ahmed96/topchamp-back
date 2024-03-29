class Reports::AdminController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  #todo revenue and subtotal
  def revenue
    user = revenue_params[:user_id].present? ? User.find(revenue_params[:user_id]) : @resource
    search = params[:event_name].strip unless params[:event_name].nil?
    column = params[:column].nil? ? 'event_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    items = Event.my_order(column, direction).only_creator(user.id)
                .title_like(search).select("events.id AS event_id, events.title AS event_name,"+
                                               "(SELECT COUNT(sch.id) FROM event_schedules AS sch WHERE sch.event_id = events.id) AS number_agenda_item,"+
                                               "COALESCE((SELECT SUM(pym1.amount) FROM payment_transactions AS pym1 WHERE pym1.event_id = events.id AND pym1.description = 'SchedulePayment'), 0) AS net_revenue")
                .group("events.id")
    json_response_serializer_collection items, RevenueReportSerializer
  end

  #todo revenue and subtotal
  def report
    search = params[:event_name].strip unless params[:event_name].nil?
    column = params[:column].nil? ? 'event_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    items = Event.my_order(column, direction).where(:creator_user_id => user_id).joins(participants: [:attendee_types]).merge(Participant.where :user_id => user_id).merge(AttendeeType.where :id => AttendeeType.director_id)
                .title_like(search).select("events.id AS event_id, events.title AS event_name, 0 AS net_income, "+
                                               "0 AS payment_recived,"+
                                               "0 AS account_balance")
                .group("events.id")
    json_response_serializer_collection items, AdminReportSerializer
  end

  private

  def user_id
    params.require('user_id')
    params.permit('user_id')
    params['user_id']
  end

  def revenue_params
    params.require('user_id')
    params.permit('user_id')
  end
end
