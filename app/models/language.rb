class Language < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :name, presence: true
  validates :locale, presence: true

  scope :name_like, lambda {|search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :locale_like, lambda {|search| where ["LOWER(locale) LIKE LOWER(?)", "%#{search}%"] if search.present?}

  swagger_schema :Language do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :locale do
      key :type, :string
    end
  end

  swagger_schema :LanguageInput do
    key :required, [:name, :locale]
    property :name do
      key :type, :string
    end
    property :locale do
      key :type, :string
    end
  end
end
