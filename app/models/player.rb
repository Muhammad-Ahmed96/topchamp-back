class Player < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  before_create :set_status
  belongs_to :user
  belongs_to :event
  belongs_to :attendee_type, :optional => true
  has_many :brackets, class_name: "PlayerBracket", dependent: :destroy
  has_many :brackets_enroll, -> {enroll}, class_name: "PlayerBracket"
  has_many :brackets_wait_list, -> {wait_list}, class_name: "PlayerBracket"
  has_and_belongs_to_many :schedules, :class_name => "EventSchedule"
  has_and_belongs_to_many :teams #dependent: :delete_all

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
    if self.user.present? and self.user.association_information.present?
      self.user.association_information.raking
    end
  end

  def sync_brackets!(data)
    brackets_ids = []
    schedules_ids = self.schedule_ids
    any_one = false
    event = self.event
    if data.present? and data.kind_of?(Array)
      data.each do |bracket|
        #get bracket to enroll
        current_bracket = EventBracket.where(:event_id => event.id).where(:id => bracket[:event_bracket_id]).first
        # check if category exist in event
        category = self.event.internal_categories.where(:id => bracket[:category_id]).count
        if current_bracket.present? and category > 0
          status = current_bracket.get_status(bracket[:category_id])
          save_data = {:category_id => bracket[:category_id], :event_bracket_id => bracket[:event_bracket_id]}
          saved_bracket = self.brackets.where(:category_id => save_data[:category_id]).where(:event_bracket_id => save_data[:event_bracket_id]).update_or_create!(save_data)
          if saved_bracket.enroll_status != "enroll"
            saved_bracket.enroll_status = status
            saved_bracket.save!
          end
          brackets_ids << saved_bracket.id
          #save schedule on player
          shedules = event.schedules.where(:category_id => bracket[:category_id]).where(:agenda_type_id => AgendaType.competition_id).pluck(:id)
          schedules_ids = schedules_ids + shedules
          if any_one == false and shedules.length > 0
            any_one = true
          end
        end
      end
      if any_one
        self.schedule_ids = schedules_ids
      end
    end
    #delete other brackets
    self.brackets.where.not(:id => brackets_ids).destroy_all
    if self.status == "Inactive" and self.brackets.count > 0
      self.activate
    end
  end


  def set_teams
    User.create_teams(self.brackets_enroll, self.user_id, event.id)
  end

  def set_paid(data, reference)
    User.create_teams(self.brackets_enroll, self.user_id, event.id)
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
        key :'$ref', :EventBracket
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
    property :schedules do
      key :type, :array
      items do
        key :'$ref', :EventSchedule
      end
      key :description, "Schedules associated with player"
    end
  end

  def categories
    categories = []
    self.brackets.each {|bracket| categories << bracket.category if categories.detect {|w| w.id == bracket.category.id}.nil?}
    categories
  end

  def sports
    self.event.sports
  end

  #validate partner complete information
  def validate_partner(partner_id, bracket_id, category_id)
    total = 4
    current = 0
    category_type = ""
    if [category_id.to_i].included_in? Category.doubles_categories
      category_type = "partner_double"
    elsif [category_id.to_i].included_in? Category.mixed_categories
      category_type = "partner_mixed"
    end
    invitation = Invitation.where(:user_id => partner_id, :sender_id => self.user_id, :status => :role).where(:invitation_type => category_type)
                     .joins(:brackets).merge(InvitationBracket.where(:event_bracket_id => bracket_id)).first
    partner_player = Player.where(user_id: partner_id).where(event_id: event_id).first
    if partner_player.present?
      #Complete requiered fields in their profiles
      if partner_player.user.first_name.present? and partner_player.user.last_name.present?
        current = current + 1
      end
      #Event fee paid
      if partner_player.event.is_paid
        current = current + 1
      end
      #Brackets fee paid
      partner_bracket = partner_player.brackets.where(:event_bracket_id => bracket_id, :category_id => category_id).first
      if partner_bracket.present? and partner_bracket.payment_transaction_id.present?
        current = current + 1
      end
    end
    #Invitation accepted
    if invitation.present?
      current = current + 1
    end
    if current == total
      return invitation
    else
      nil
    end
  end


  def unsubscribe_event
    self.brackets.each do |bracket|
      self.unsubscribe(bracket.category_id, bracket.event_bracket_id)
    end
  end

  def unsubscribe(category_id, event_bracket_id)
    event = self.event
    brackets = self.brackets.where(:event_bracket_id => event_bracket_id).where(:category_id => category_id).where(:enroll_status => :enroll).all
    brackets.each do |bracket|
      team = Team.joins(:players).merge(Player.where(:id => self.id)).where(:event_id => event.id)
                 .where(:category_id => category_id).where(:event_bracket_id => event_bracket_id).first
      if team.present?
        self.teams.destroy(team)
      end
      bracket.destroy
    end
    teams_ids = Team.where(:category_id => category_id).where(:event_bracket_id => event_bracket_id).where(:event_id => event.id).pluck(:id)
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
    bracket = EventBracket.where(:id => event_bracket_id).first
    category = Category.find(category_id)
    director = User.find(event.creator_user_id)
    registrant = self.user
    UnsubscribeMailer.unsubscribe(bracket, category, director, registrant, event).deliver

    free_spaces = bracket.get_free_count(category_id)
    if free_spaces.present? and free_spaces == 1
      url =  Rails.configuration.front_new_spot_url.gsub "{event_id}", event.id.to_s
      url =  url.gsub "{event_bracket_id}", bracket.id.to_s
      url =  url.gsub "{category_id}", category.id.to_s
      url = Invitation.short_url url
      players = self.event.players.joins(:brackets_wait_list).merge(PlayerBracket.where(:category_id => category_id).where(:event_bracket_id => event_bracket_id)).all
      players.each do |player|
        UnsubscribeMailer.spot_open(player, event, url).deliver
      end
      EventBracketFree.where(:event_bracket_id => bracket.id).where(:category_id => category.id)
          .update_or_create!({:event_bracket_id => bracket.id, :category_id => category.id, :free_at => DateTime.now,
                             :url => url})
    end

  end

  def inactivate
    self.status = "Inactive"
    self.save!(:validate => false)
  end

  def activate
    self.status = "Active"
    self.save!(:validate => false)
  end

  def tournaments
    self.event.tournaments.joins(rounds: [matches: [team_a: :players]]).merge(Player.where(:id => self.id))
    .joins(rounds: [matches: [team_b: :players]]).merge(Player.where(:id => self.id))
  end

  private

  def set_status
    self.status = :Active
    self.attendee_type_id = AttendeeType.player_id
  end

end
