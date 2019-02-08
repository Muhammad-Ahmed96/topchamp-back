class ProcessingFeeSerializer < ActiveModel::Serializer
  attributes :id, :title, :amount_director, :amount_registrant
end
