class LanguageSerializer < ActiveModel::Serializer
  attributes :id, :name, :locale
end