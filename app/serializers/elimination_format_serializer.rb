class EliminationFormatSerializer < ActiveModel::Serializer
  attributes :id, :name, :index, :is_active, :slug
end
