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

  def transaction
    user_ids = Player.all.pluck(:user_id)
    column = params[:column].nil? ? 'player_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    player_name = params[:player_name].strip unless params[:player_name].nil?
    authorize_fee = params[:authorize_fee].strip unless params[:authorize_fee].nil?
    top_champ_account = params[:top_champ_account].strip unless params[:top_champ_account].nil?
    top_champ_fee = params[:top_champ_fee].strip unless params[:top_champ_fee].nil?
    director_receipt = params[:director_receipt].strip unless params[:director_receipt].nil?
    items = User.my_order(column, direction).where(:id => user_ids).joins('INNER JOIN payment_transactions AS pym ON pym.user_id = users.id')
                .select('users.id AS user_id,concat(users.first_name,\' \', users.last_name) AS player_name,' +
                                               'ROUND(SUM(pym.authorize_fee::NUMERIC), 2) AS authorize_fee,'+
                            ' ROUND(SUM(pym.account::NUMERIC), 2) AS top_champ_account, ROUND(SUM(pym.app_fee::NUMERIC), 2) AS top_champ_fee,ROUND(SUM(pym.director_receipt::NUMERIC), 2) AS director_receipt')
                .group("users.id")

    unless player_name.nil?
      items = items.where("LOWER(concat(users.first_name,' ', users.last_name)) LIKE LOWER(?)", "%#{player_name}%")
    end

    unless authorize_fee.nil?
      items = items.having("ROUND(SUM(pym.authorize_fee::NUMERIC), 2) = ?", authorize_fee)
    end
    unless top_champ_account.nil?
      items = items.having(' ROUND(SUM(pym.account::NUMERIC), 2) = ?', top_champ_account)
    end
    unless top_champ_fee.nil?
      items = items.having(' ROUND(SUM(pym.app_fee::NUMERIC), 2) = ?', top_champ_fee)
    end
    unless director_receipt.nil?
      items = items.having(' ROUND(SUM(pym.director_receipt::NUMERIC), 2) = ?', director_receipt)
    end
    json_response_serializer_collection items, TransactionsReportSerializer

  end

  private

  def user_id
    params.require('user_id')
    params.permit('user_id')
    params['user_id']
  end
end
