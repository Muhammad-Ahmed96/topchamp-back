class User < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  attr_accessor :is_my_partner
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable

  has_and_belongs_to_many :sports
  has_one :contact_information, :dependent => :destroy
  has_one :billing_address, :dependent => :destroy
  has_one :shipping_address, :dependent => :destroy
  has_one :association_information, :dependent => :destroy
  has_one :medical_information, :dependent => :destroy
  has_many :players, :dependent => :destroy
  has_many :participants, :dependent => :destroy
  has_many :wait_lists, :dependent => :destroy
  has_many :devices
  has_many :event_reminders, :class_name => 'UserEventReminder'

  has_attached_file :profile, :path => ":rails_root/public/images/user/:to_param/:style/:basename.:extension",
                    :url => "/images/user/:to_param/:style/:basename.:extension",
                    styles: {medium: "300X300>", thumb: "50x50>"}, default_url: "/assets/user/:style/avatar_profile.png"

  # authenticate :resend_limit, if: :new_record?
  #authenticate :valid_pin, unless: :new_record?
  after_initialize :set_random_pin!, if: :new_record?
  after_initialize :set_random_membership_id!, if: :new_record?
  #validates_attachment :profile
  #validate :check_dimensions
  #validates_with AttachmentSizeValidator, attributes: :profile, less_than: 2.megabytes
  validates_attachment_content_type :profile, content_type: /\Aimage\/.*\z/

  validates :first_name, length: {maximum: 50}, presence: true
  validates :middle_initial, length: {maximum: 1}
  validates :last_name, length: {maximum: 50}, presence: true
  validates :badge_name, length: {maximum: 50}
  #validates :birth_date, presence: true
  #validates :gender, inclusion: {in: Genders.collection}
  #validates :role, inclusion: {in: Roles.collection}
  validates :password, presence: false
  include DeviseTokenAuth::Concerns::User


  scope :in_status, lambda {|status| where status: status if status.present?}
  scope :in_role, lambda {|role| where role: role if role.present?}
  scope :birth_date_in, lambda {|birth_date| where birth_date: birth_date if birth_date.present?}
  scope :search, lambda {|search| where ["LOWER(first_name) LIKE LOWER(?) OR LOWER(last_name) like LOWER(?)", "%#{search}%", "%#{search}%"] if search.present?}
  scope :first_name_like, lambda {|search| where ["LOWER(first_name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :last_name_like, lambda {|search| where ["LOWER(last_name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :gender_like, lambda {|search| where ["LOWER(gender) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :email_like, lambda {|search| where ["LOWER(email) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :last_sign_in_at_in, lambda {|search| where last_sign_in_at: search.beginning_of_day..search.end_of_day if search.present?}
  scope :last_sign_in_at_like, lambda {|search| where("LOWER(concat(trim(to_char(last_sign_in_at, 'Month')),',',to_char(last_sign_in_at, ' DD, YYYY'))) LIKE LOWER(?)", "%#{search}%") if search.present?}
  scope :state_like, lambda {|search| joins(:contact_information).merge(ContactInformation.where ["LOWER(state) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :city_like, lambda {|search| joins(:contact_information).merge(ContactInformation.where ["LOWER(city) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :sport_in, lambda {|search| joins(:sports).merge(Sport.where id: search) if search.present?}
  scope :contact_information_order, lambda {|column, direction = "desc"| includes(:contact_information).order("contact_informations.#{column} #{direction}") if column.present?}
  scope :sports_order, lambda {|column, direction = "desc"| includes(:sports).order("sports.#{column} #{direction}") if column.present?}


  def self.active
    where(status: :Active)
  end

  def self.inactive
    where(status: :Inactive)
  end

  def sysadmin?
    self.try(:role) == "Sysadmin"
  end

  def director?
    self.try(:role) == "Director"
  end

  def agent?
    self.try(:role) == "Agent"
  end

  def member?
    self.try(:role) == "Member"
  end

  def customer?
    self.try(:role) == "Customer"
  end

  def is_director
    count = self.participants.joins(:attendee_types).merge(AttendeeType.where :id => AttendeeType.director_id).count
    if count > 0
      return true
    else
      return false
    end
  end

  def is_player
    count = self.participants.joins(:attendee_types).merge(AttendeeType.where :id => AttendeeType.player_id).count
    if count > 0
      return true
    else
      return false
    end
  end

  def my_events
    Event.only_directors(self.id).pluck(:id)
  end

  swagger_schema :UserLogin do
    key :required, [:id, :email, :provider, :uid, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :image, :badge_name]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with user"
    end
    property :email do
      key :type, :string
      key :description, "Email associated with user"
    end
    property :provider do
      key :type, :string
      key :description, "Provider associated with user"
    end
    property :uid do
      key :type, :string
      key :description, "Uid associated with user"
    end
    property :first_name do
      key :type, :string
      key :description, "First name associated with user"
    end
    property :middle_initial do
      key :type, :string
      key :description, "Middle initial associated with user"
    end
    property :last_name do
      key :type, :string
      key :description, "Last name associated with user"
    end
    property :gender do
      key :type, :string
      key :description, "Gender associated with user"
    end
    property :role do
      key :type, :string
      key :description, "Role associated with user"
    end
    property :birth_date do
      key :type, :string
      key :description, "Birth date associated with user"
    end
    property :badge_name do
      key :type, :string
      key :description, "Badge name associated with user"
    end
  end


  swagger_schema :User do
    key :required, [:id, :email, :provider, :uid, :allow_password_change, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :profile, :badge_name, :sports, :contact_information,
                    :shipping_address, :association_information, :medical_information]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with user"
    end
    property :first_name do
      key :type, :string
      key :description, "First name associated with user"
    end
    property :last_name do
      key :type, :string
      key :description, "Last name associated with user"
    end
    property :gender do
      key :type, :string
      key :description, "Gender associated with user"
    end
    property :email do
      key :type, :string
      key :description, "Email associated with user"
    end
    property :badge_name do
      key :type, :string
      key :description, "Badge name associated with user"
    end
    property :birth_date do
      key :type, :string
      key :description, "Birth date associated with user"
    end
    property :middle_initial do
      key :type, :string
      key :description, "Middle initial associated with user"
    end
    property :role do
      key :type, :string
      key :description, "Role associated with user"
    end
    property :profile do
      key :type, :string
      key :description, "Profile associated with user"
    end
    property :status do
      key :type, :string
      key :description, "Status associated with user"
    end
    property :last_sign_in_at do
      key :type, :string
      key :description, "Last sign in at associated with user"
    end

    property :is_receive_text do
      key :type, :boolean
      key :description, "is receive text associated with user"
    end
    property :membership_id do
      key :type, :string
      key :description, "Membership id associated with user"
    end

    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
      key :description, "Sports associated with user"
    end
    property :contact_information do
      key :'$ref', :ContactInformation
      key :description, "Contact information associated with user"
    end

    property :shipping_address do
      key :'$ref', :ShippingAddress
      key :description, "Shipping address associated with user"
    end

    property :association_information do
      key :'$ref', :AssociationInformation
      key :description, "Association information associated with user"
    end


    property :medical_information do
      key :'$ref', :MedicalInformation
      key :description, "Medical information associated with user"
    end

    property :players do
      key :type, :array
      items do
        key :'$ref', :Player
      end
      key :description, "Players associated with user"
    end
  end


  swagger_schema :UserInput do
    key :required, [:email, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :badge_name]

    property :first_name do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :gender do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
    property :badge_name do
      key :type, :string
    end
    property :birth_date do
      key :type, :string
    end
    property :middle_initial do
      key :type, :string
    end
    property :role do
      key :type, :string
    end
    property :profile do
      key :type, :string
    end
    property :status do
      key :type, :string
    end
    property :last_sign_in_at do
      key :type, :string
    end
    property :is_receive_text do
      key :type, :boolean
    end
    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
    end
    property :contact_information do
      key :'$ref', :ContactInformationInput
    end

    property :shipping_address do
      key :'$ref', :ShippingAddressInput
    end

    property :billing_address do
      key :'$ref', :BillingAddressInput
    end

    property :association_information do
      key :'$ref', :AssociationInformationInput
    end


    property :medical_information do
      key :'$ref', :MedicalInformationInput
    end
  end

  def resend_limit
    if self.profile.activations.where(created_at: (1.day.ago..Time.now)).count >= 3
      errors.add(:base, 'You have reached the maximum allow number of reminders!')
    end
  end

  def set_random_pin!
    generated = 0
    loop do
      generated = rand(000000..999999).to_s.rjust(6, "0")
      other = User.find_by_pin(generated)
      break if other.nil?
    end
    self.pin = generated
  end

  def set_random_membership_id!
    generated = 0
    loop do
      generated = rand(0000000000..9999999999).to_s.rjust(10, "0")
      other = User.find_by_membership_id(generated)
      break if other.nil?
    end
    self.membership_id = generated
  end

  def valid_pin
    unless response_pin.present? && response_pin == pin
      errors.add(:response_pin, 'Incorrect pin number')
    end
  end


  def valid_birthdate?(value)
    self.birth_date.to_s == value
  end

  def valid_mobile?(value)
    if self.contact_information.present?
      self.contact_information.cell_phone.to_s == value || (self.contact_information.country_code_phone + self.contact_information.cell_phone.to_s) == value
    else
      false
    end
  end

  def age
    if self.birth_date.present?
      (Time.now.to_s(:number).to_i - self.birth_date.to_time.to_s(:number).to_i) / 10e9.to_i
    else
      0
    end

  end

  def self.create_teams(brackets, user_root_id, event_id, parent_root = false)
    #ckeck partner brackets
    brackets.each do |item|
      exist = EventContestCategoryBracketDetail.where(:id => item[:event_bracket_id]).first
      unless exist.nil?
        category_type = ""
        if [item[:category_id].to_i].included_in? Category.doubles_categories
          category_type = "partner_double"
        elsif [item[:category_id].to_i].included_in? Category.mixed_categories
          category_type = "partner_mixed"
        end
        invitation = Invitation.where(:event_id => event_id).where(:user_id => user_root_id).where(:status => :accepted).where(:invitation_type => category_type)
                         .joins(:brackets).merge(InvitationBracket.where(:event_bracket_id => item[:event_bracket_id])).first
        if invitation.present?
          result = self.create_partner(invitation.sender_id, event_id, invitation.user_id, item[:event_bracket_id], item[:category_id],
                                       parent_root)
        else
          #if [item[:category_id].to_i].included_in? Category.single_categories
          player = Player.where(user_id: user_root_id).where(event_id: event_id).first_or_create!
          self.create_team(user_root_id, event_id, item[:event_bracket_id], item[:category_id], [player.id])
          #end
        end
      end
    end
  end

  def self.create_partner(user_root_id, event_id, partner_id, event_bracket_id, category_id, partner_main = false)
    user_id_main = partner_main ? partner_id : user_root_id
    user_id_partner = partner_main ? user_root_id : partner_id
    player = Player.where(user_id: user_id_main).where(event_id: event_id).first
    partner_player = Player.where(user_id: user_id_partner).where(event_id: event_id).first
    if player.nil?
      return false
    end
    result = player.validate_partner(user_id_partner, user_id_main, event_bracket_id, category_id)
    if result != true
      if partner_main
        self.create_team(user_id_main, event_id, event_bracket_id, category_id, [player.id])
      end
      return false
    end
    if partner_player.nil?
      return false
    end
    self.create_team(user_root_id, event_id, event_bracket_id, category_id, [player.id, partner_player.id])
    return true
  end


  def self.create_team(user_root_id, event_id, event_bracket_id, category_id, players_ids)
    count = Team.where(event_id: event_id).where(event_bracket_id: event_bracket_id)
                .where(:category_id => category_id).count
    team_exist = Team.where(event_id: event_id).where(event_bracket_id: event_bracket_id)
                     .where(:creator_user_id => user_root_id).where(:category_id => category_id).first
    team_name = 'Team 1'
    if team_exist.present?
      if team_exist.name.nil?
        team_name = "Team #{count + 1}"
      else
        team_name = team_exist.name
      end
    else
      team_name = "Team #{count + 1}"
    end

    team = Team.where(event_id: event_id).where(event_bracket_id: event_bracket_id)
               .where(:creator_user_id => user_root_id).where(:category_id => category_id)
               .update_or_create!({:name => team_name, :event_id => event_id, :event_bracket_id => event_bracket_id,
                                   :creator_user_id => user_root_id, :category_id => category_id})
    team.player_ids = players_ids
    #find and delete old teams
    players = team.players.where.not(:user_id => user_root_id).all
    players.each do |player|
      team_fetch = Team.joins(:players).merge(Player.where(:id => player.id)).where(:event_id => event_id)
                       .where(:category_id => category_id).where(:event_bracket_id => event_bracket_id)
                       .where.not(:id => team.id).first
      if team_fetch.present?
        player.teams.destroy(team_fetch)
      end
    end
    teams_ids = Team.where(:category_id => category_id).where(:event_bracket_id => event_bracket_id).where(:event_id => event_id).pluck(:id)
    teams_to_destroy = []
    teams_ids.each do |team_id|
      count = Team.where(:id => team_id).first.players.count
      if count == 0
        teams_to_destroy << team_id
      end
    end
    if teams_to_destroy.length > 0
      Team.where(:id => teams_to_destroy).destroy_all
    end
  end


  def is_my_partner
    #get my partners ids
    my_players_ids = Current.user.players.pluck(:id)
    teams_ids = Team.joins(:players).merge(Player.where(:id => my_players_ids)).pluck(:id)
    players_ids = Player.where.not(:id => my_players_ids).joins(:teams).merge(Team.where(:id => teams_ids)).pluck(:id)
    partners_ids = User.joins(:players).merge(Player.where(:id => players_ids)).pluck(:id)
    return [self.id].included_in? partners_ids
  end

  def skill_level
    level = 0
    if self.association_information.present?
      level = self.association_information.raking
    end
    level
  end

  def sync_wait_list(data, event_id)
    if data.present? and data.kind_of?(Array)
      data.each do |bracket|
        saveData = {:event_bracket_id => bracket[:event_bracket_id], :category_id => bracket[:category_id], :event_id => event_id}
        self.wait_lists.where(:event_bracket_id => saveData[:event_bracket_id]).where(:category_id => saveData[:category_id])
            .update_or_create!(saveData)
      end
    end
  end

  def sync_personalized_discount(data)
    deleteIds = []
    if data.present? and data.kind_of?(Array)
      data.each do |discount|
        discount.delete(:id)
        discount = EventPersonalizedDiscount.where(:email => discount[:email]).where(:code => discount[:code])
                       .update_or_create!(discount)
        deleteIds << discount.id
      end
    end
    EventPersonalizedDiscount.where.not(id: deleteIds).destroy_all
  end

  private

  def check_dimensions
    required_width = 300
    required_height = 300
    temp_file = profile.queued_for_write[:original]
    unless temp_file.nil?
      dimensions = Paperclip::Geometry.from_file(temp_file.path)
      errors.add(:image, "Maximun width must be #{required_width}px") unless dimensions.width <= required_width
      errors.add(:image, "Maximun height must be #{required_height}px") unless dimensions.height <= required_height
    end
  end

  protected

  def get_contest
    contest_id = PlayerBracket.joins(:player).merge(Player.where(:user_id => self.id)).pluck(:contest_id)
    EventContest.where(:id => contest_id)
  end

end
