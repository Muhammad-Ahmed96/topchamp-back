class Player < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  before_create :set_status
  belongs_to :user
  belongs_to :event
  belongs_to :attendee_type, :optional => true
  has_many :brackets, class_name: "PlayerBracket"
  has_many :brackets_enroll,-> {enroll}, class_name: "PlayerBracket"
  has_many :brackets_wait_list, -> {wait_list}, class_name: "PlayerBracket"

  has_many :payment_transactions, class_name: 'Payments::PaymentTransaction', :as => :transactionable

  has_attached_file :signature, :path => ":rails_root/public/images/player/:to_param/:style/:basename.:extension",
                    :url => "/images/player/:to_param/:style/:basename.:extension",
                    styles: {medium: "100X100>", thumb: "50x50>"}, default_url: "/assets/missing.png"
  validates_attachment_content_type :signature, content_type: /\Aimage\/.*\z/

  scope :status_in, lambda {|status| where status: status if status.present?}
  #scope :skill_level_like, lambda {|search| where ["to_char(skill_level,'9999999999') LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :event_like, lambda {|search| joins(:event).merge(Event.where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :first_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(first_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :last_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(last_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :email_like, lambda {|search| joins(:user).merge(User.where ["LOWER(email) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :skill_level_like, lambda {|search| joins(user: [:association_information]).merge(AssociationInformation.where ["LOWER(raking) LIKE LOWER(?)", "%#{search}%"]) if search.present?}

  scope :sport_in, lambda {|search| joins(event: [:sports]).merge(Sport.where id: search) if search.present?}
  scope :role_in, lambda {|search| joins(:user).merge(User.where role: search) if search.present?}
  scope :bracket_in, lambda {|search| joins(:event).merge(Event.where bracket_by: search) if search.present?}
  scope :category_in, lambda {|search| joins(brackets: [:category]).merge(Category.where id: search) if search.present?}



  scope :event_order, lambda {|column, direction = "desc"| joins(:event).order("events.#{column} #{direction}") if column.present?}
  scope :first_name_order, lambda {|column, direction = "desc"| joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :last_name_order, lambda {|column, direction = "desc"| joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :email_order, lambda {|column, direction = "desc"| joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :sports_order, lambda {|column, direction = "desc"| includes(event: [:sports]).order("sports.#{column} #{direction}") if column.present?}
  scope :skill_level_order, lambda {|column, direction = "desc"| includes(user: [:association_information]).order("association_informations.#{column} #{direction}") if column.present?}
  scope :categories_order, lambda {|column, direction = "desc"| joins(brackets: [:category]).order("categories.#{column} #{direction}") if column.present?}

  def skill_level
    if self.user.association_information.present?
      self.user.association_information.raking
    end
  end

  def sync_brackets!(data)
    brackets_ids = []
    if data.present? and data.kind_of?(Array)
      data.each do |bracket|
        #get bracket to enroll
        current_bracket = EventBracket.where(:event_id => self.event.id).where(:id => bracket[:event_bracket_id]).first
        # check if category exist in event
        category = self.event.internal_categories.where(:id => bracket[:category_id]).count
        if current_bracket.present? and category > 0
          status = current_bracket.get_status(bracket[:category_id])
          save_data = {:category_id => bracket[:category_id], :event_bracket_id => bracket[:event_bracket_id]}
          saved_bracket = self.brackets.where(:category_id  => save_data[:category_id]).where(:event_bracket_id => save_data[:event_bracket_id]).update_or_create!(save_data)
          if saved_bracket.enroll_status != "enroll"
            saved_bracket.enroll_status = status
            saved_bracket.save!
          end
          brackets_ids << saved_bracket.id
        end
      end
    end
    #delete other brackets
    self.brackets.where.not(:id => brackets_ids).destroy_all
  end

  swagger_schema :Player do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with player"
    end
    property :skill_level do
      key :type, :string
      key :description, "Skill level associated with player"
    end
    property :status do
      key :type, :string
      key :description, "status associated with player"
    end
    property :categories do
      key :type, :array
      items do
        key :'$ref', :Category
      end
      key :description, "Categories associated with player"
    end

    property :brackets do
      key :type, :array
      items do
        key :'$ref', :EventBracketAge
      end
      key :description, "Brackets associated with player"
    end

    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
      key :description, "Sports associated with player"
    end
    property :user do
      key :'$ref', :User
      key :description, "User associated with player"
    end
    property :event do
      key :'$ref', :EventSingle
      key :description, "Event associated with player"
    end
    property :signature do
      key :type, :string
      key :description, "Url signature associated with player"
    end
  end

  def categories
    categories = []
    self.brackets.each {|bracket| categories << bracket.category if categories.detect{|w| w.id == bracket.category.id}.nil? }
    categories
  end

  def sports
    self.event.sports
  end
  private
  def set_status
    self.status = :Active
    self.attendee_type_id = AttendeeType.player_id
  end

end
