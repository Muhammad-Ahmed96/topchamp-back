class Player < ApplicationRecord
  include Swagger::Blocks
  belongs_to :user
  belongs_to :event
  has_and_belongs_to_many :event_enrolls

  scope :status_in, lambda {|status| where status: status if status.present?}
  scope :skill_level_like, lambda {|search| where ["to_char(skill_level,'9999999999') LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :event_like, lambda {|search| joins(:event).merge(Event.where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :first_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(first_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :last_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(last_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :email_like, lambda {|search| joins(:user).merge(User.where ["LOWER(email) LIKE LOWER(?)", "%#{search}%"]) if search.present?}

  scope :sport_in, lambda {|search| joins(user: [:sports]).merge(Sport.where id: search) if search.present?}
  scope :category_in, lambda {|search| joins(event_enrolls: [:category]).merge(Category.where id: search) if search.present?}
  scope :bracket_age_in, lambda {|search| joins(event_enrolls: [:bracket_age]).merge(EventBracketAge.where id: search) if search.present?}
  scope :bracket_skill_in, lambda {|search| joins(event_enrolls: [:bracket_skill]).merge(EventBracketSkill.where id: search) if search.present?}


  scope :event_order, lambda {|column, direction = "desc"| joins(:event).order("events.#{column} #{direction}") if column.present?}
  scope :first_name_order, lambda {|column, direction = "desc"| joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :last_name_order, lambda {|column, direction = "desc"| joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :email_order, lambda {|column, direction = "desc"| joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :sports_order, lambda {|column, direction = "desc"| includes(user: [:sports]).order("sports.#{column} #{direction}") if column.present?}


  scope :categories_order, lambda {|column, direction = "desc"| joins(event_enrolls: [:category]).order("categories.#{column} #{direction}") if column.present?}
  scope :bracket_age_order, lambda {|column, direction = "desc"| includes(event_enrolls: [:bracket_age]).order("event_bracket_ages.#{column} #{direction}") if column.present?}
  scope :bracket_skill_order, lambda {|column, direction = "desc"| includes(event_enrolls: [:bracket_skill]).order("event_bracket_skills.#{column} #{direction}") if column.present?}


  swagger_schema :Player do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :skill_level do
      key :type, :string
    end
    property :status do
      key :type, :string
    end
    property :categories do
      key :type, :array
      items do
        key :'$ref', :Category
      end
    end

    property :brackets do
      key :type, :array
      items do
        key :'$ref', :EventBracketAge
      end
    end

    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
    end
    property :user do
      key :'$ref', :User
    end
    property :event do
      key :'$ref', :EventSingle
    end
  end

end
