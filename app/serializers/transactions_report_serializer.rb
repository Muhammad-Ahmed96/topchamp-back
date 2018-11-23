class TransactionsReportSerializer < ActiveModel::Serializer
  attributes :user_id, :player_name, :authorize_fee, :top_champ_account, :top_champ_fee, :director_receipt
end
