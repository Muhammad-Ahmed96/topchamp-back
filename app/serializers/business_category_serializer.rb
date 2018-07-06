class BusinessCategorySerializer < ActiveModel::Serializer
  attributes :id, :code,:group, :description
end
