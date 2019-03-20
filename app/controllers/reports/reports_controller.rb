class Reports::ReportsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def account
    user = account_params[:user_id].present? ? User.find(account_params[:user_id]) : @resource
    search = params[:event_name].strip unless params[:event_name].nil?
    column = params[:column].nil? ? 'event_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    items = Event.my_order(column, direction).only_creator(user.id)
                .title_like(search).select("events.id AS event_id, events.title AS event_name,"+
                                           "COALESCE((SELECT SUM(pym1.amount) FROM payment_transactions AS pym1 WHERE pym1.event_id = events.id),0) AS gross_income,"+
                                           "COALESCE((SELECT SUM(pym2.director_receipt) FROM payment_transactions AS pym2 WHERE pym2.event_id = events.id),0)AS net_income,"+
                                           "COALESCE((SELECT SUM(rfd1.total) FROM refund_transactions AS rfd1 WHERE rfd1.event_id = events.id),0) AS refund,"+
                                               "COALESCE((SELECT SUM(pym3.director_receipt) FROM payment_transactions AS pym3 WHERE pym3.event_id = events.id),0) -"+
                                               " COALESCE((SELECT SUM(rfd2.total) FROM refund_transactions AS rfd2 WHERE rfd2.event_id = events.id),0) AS balance")
                .group("events.id")
    #items.each do |item|
     # gross_income = number_with_precision(Payments::PaymentTransaction.where(:event_id => item.event_id).sum(:amount),precision: 2).to_f
      #net_income =  number_with_precision(Payments::PaymentTransaction.where(:event_id => item.event_id).sum(:director_receipt),precision: 2).to_f
      #refunds = number_with_precision(Payments::RefundTransaction.where(:event_id => item.event_id).sum(:total),precision: 2).to_f
      #item.gross_income = gross_income
      #item.net_income = net_income
     # item.refund = refunds
      #item.balance = 0 - 0
    #end
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
    my_events_ids = params[:event_id].nil? ? Event.only_creator(@resource.id).pluck(:id) : params[:event_id]
    items = User.my_order(column, direction).where(:id => user_ids).joins('INNER JOIN payment_transactions AS pym ON pym.user_id = users.id')
    .where("pym.event_id IN (?) AND pym.for_refund = true AND pym.amount > pym.refund_total", my_events_ids)
                .select('users.id AS user_id,concat(users.first_name,\' \', users.last_name) AS player_name,pym.payment_transaction_id ,' +
                                               'ROUND(SUM(pym.authorize_fee::NUMERIC), 2) AS authorize_fee,'+
                            ' ROUND(SUM(pym.account::NUMERIC), 2) AS top_champ_account, ROUND(SUM(pym.app_fee::NUMERIC), 2) AS top_champ_fee, ' +
                            'ROUND(SUM(pym.director_receipt::NUMERIC), 2) AS director_receipt, ROUND(SUM(pym.amount::NUMERIC), 2) AS amount,' +
                            ' pym.event_id AS event_id')
                .group("users.id", 'pym.payment_transaction_id')

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

  def account_params
    params.permit('user_id')
  end
end
