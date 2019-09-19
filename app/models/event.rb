require 'google/apis/webmasters_v3'
require 'google/apis/translate_v2'
require 'google/api_client/client_secrets'
require 'json'
require "uri"
require "net/http"

class Event < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  attr_accessor :reminder
  # attr_accessor :gross_income
  # attr_accessor :net_income
  #attr_accessor :refund
  #attr_accessor :balance

  has_and_belongs_to_many :sports
  has_and_belongs_to_many :regions
  #has_and_belongs_to_many :internal_categories, :join_table => "categories_events", class_name: "Category"
  # has_many :categories, :class_name => "CategoriesEvent"
  belongs_to :venue, optional: true
  belongs_to :event_type, optional: true
  has_one :payment_information, class_name: 'EventPaymentInformation'
  has_one :payment_method, class_name: 'EventPaymentMethod'
  has_one :discount, class_name: 'EventDiscount'
  has_many :discount_generals, class_name: 'EventDiscountGeneral'
  has_many :discount_personalizeds, class_name: 'EventDiscountPersonalized'
  has_one :tax, class_name: 'EventTax'
  has_many :players
  has_many :participants
  has_one :registration_rule, class_name: 'EventRegistrationRule'
  belongs_to :director, class_name: 'User', :foreign_key => "creator_user_id"
  #has_one :rule, class_name: 'EventRule'
  #belongs_to :sport_regulator, optional: true
  #belongs_to :elimination_format, optional: true
  has_many :tournaments
  has_many :teams
  has_many :event_reminders, :class_name => 'UserEventReminder'
  has_many :contests, :class_name => 'EventContest'


  has_one :payment_transaction, class_name: 'Payments::PaymentTransaction', :as => :transactionable

  #has_many :brackets, -> {only_parent}, class_name: "Event"
  #has_many :internal_brackets, class_name: "EventBracket"
  has_many :schedules, class_name: "EventSchedule"


  # belongs_to :scoring_option_match_1, foreign_key: "scoring_option_match_1_id", class_name: "ScoringOption", optional: true
  #belongs_to :scoring_option_match_2, foreign_key: "scoring_option_match_2_id", class_name: "ScoringOption", optional: true


  #validates :bracket_by, inclusion: {in: Bracket.collection.keys.map(&:to_s)}, :allow_nil => true
  accepts_nested_attributes_for :discount_generals
  accepts_nested_attributes_for :discount_personalizeds

  after_initialize :save_creator!, if: :new_record?

  has_attached_file :icon, :path => ":rails_root/public/images/event_icons/:to_param/:style/:basename.:extension",
                    :url => "/images/event_icons/:to_param/:style/:basename.:extension",
                    styles: {medium: "300X300>", thumb: "50x50>"}, default_url: "/assets/event/:style/default_noevent.png"
  #validates_attachment :icon
  #validate :check_dimensions
  #validates_with AttachmentSizeValidator, attributes: :icon, less_than: 2.megabytes
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/

  validates :title, presence: true
  validates :event_url, uniqueness: true, url: true, :allow_nil => true
  #validates :event_type_id, presence: true
  validates :description, length: {maximum: 1000}
  #validates :visibility, inclusion: {in: Visibility.collection.keys.map(&:to_s)}, :allow_nil => true
  #
  after_create :send_email_to_admin


  scope :in_status, lambda {|status| where status: status if status.present?}
  scope :not_in, lambda {|id| where.not id: id if id}
  scope :only_directors, lambda {|id| joins(participants: [:attendee_types]).merge(Participant.where :user_id => id).merge(AttendeeType.where :id => AttendeeType.director_id) if id.present?}
  scope :only_creator, lambda {|id| where(:creator_user_id => id) if id.present?}
  scope :in_visibility, lambda {|data| where visibility: data if data.present?}
  scope :title_like, lambda {|search| where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :url_like, lambda {|search| where ["LOWER(event_url) LIKE LOWER(?)", "%/#{search}"] if search.present?}
  scope :start_date_like, lambda {|search| where("LOWER(concat(trim(to_char(start_date, 'Month')),',',to_char(start_date, ' DD, YYYY'))) LIKE LOWER(?)", "%#{search}%") if search.present?}


  scope :state_like, lambda {|search| joins(:venue).merge(Venue.where ["LOWER(state) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :city_like, lambda {|search| joins(:venue).merge(Venue.where ["LOWER(city) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :venue_order, lambda {|column, direction = "desc"| includes(:venue).order("venues.#{column} #{direction}") if column.present?}
  # scope :distance_order, lambda {|lat, lng| joins('LEFT JOIN venues ON venues.id = events.venue_id').order("ST_Distance (ST_SetSRID(ST_MakePoint(long::double precision, lat::double precision), 4326), places.geom)") if lat.present? and lng.present?}
  # scope :distance_order, lambda {|lat, lng| select('events.*', "(point(#{lng}::double precision, #{lat}::double precision) <@> point(venues.longitude::double precision,venues.latitude::double precision)) AS distance").joins('LEFT JOIN venues ON venues.id = events.venue_id').order("distance ASC") if lat.present? and lng.present?}
  scope :distance_order, lambda {|lat, lng| joins('LEFT JOIN venues ON venues.id = events.venue_id').order("(point(#{lng}::double precision, #{lat}::double precision) <@> point(venues.longitude::double precision,venues.latitude::double precision))  ASC") if lat.present? and lng.present?}
  # scope :distance_order, lambda {|lat, lng| joins('LEFT JOIN venues ON venues.id = events.venue_id').order("ST_Distance (ST_GeographyFromText('SRID=4326;POINT(-76.000000 39.000000)'),  ST_SetSRID(ST_MakePoint(venues.longitude, venues.latitude),4326)::geography)") if lat.present? and lng.present?}

  scope :sport_in, lambda {|search| joins(:sports).merge(Sport.where id: search) if search.present?}
  scope :sports_order, lambda {|column, direction = "desc"| includes(:sports).order("sports.#{column} #{direction}") if column.present?}
  scope :end_date_order, lambda {|direction = "desc"| order("events.end_date #{direction}") if direction.present?}
  scope :start_date_order, lambda {|direction = "desc"| order("events.start_date #{direction}") if direction.present?}


  scope :end_date_greater, lambda {|date| where ["events.end_date >= ?", date] if date.present?}

  scope :coming_soon, -> {where("start_date > ?", Date.today).where("end_date > ? OR end_date is null", Date.today).where('venue_id is null')}
  scope :upcoming, -> {where("start_date > ?", Date.today).where("end_date > ? OR end_date is null", Date.today).where('venue_id is not null')}

  def sync_discount_generals!(data)
    deleteIds = []
    if data.present?
      discounts_general = nil
      data.each {|discount|
        if discount[:id].present?
          discounts_general = self.discount_generals.where(id: discount[:id]).first
          if discounts_general.present?
            discounts_general.update! discount
          else
            discount[:id] = nil
            discounts_general = self.discount_generals.create! discount
          end
        else
          discounts_general = self.discount_generals.create! discount
        end
        deleteIds << discounts_general.id
      }
    end
    self.discount_generals.where.not(id: deleteIds).destroy_all
  end

  def sync_discount_personalizeds!(data)
    deleteIds = []
    if data.present?
      discount_personalized = nil
      data.each {|discount|
        if discount[:id].present?
          discount_personalized = self.discount_personalizeds.where(id: discount[:id]).first
          if discount_personalized.present?
            discount_personalized.update! discount
          else
            discount[:id] = nil
            discount_personalized = self.discount_personalizeds.create! discount
          end
        else
          discount_personalized = self.discount_personalizeds.create! discount
        end
        deleteIds << discount_personalized.id
      }
    end
    self.discount_personalizeds.where.not(id: deleteIds).destroy_all
  end

  def sync_schedules!(data)
    deleteIds = []
    if data.present?
      schedule = nil
      data.each {|item|
        if item[:id].present?
          schedule = self.schedules.where(id: item[:id]).first
          if schedule.present?
            schedule.update! item
          else
            item[:id] = nil
            schedule = self.schedules.create! item
          end
        else
          schedule = self.schedules.create! item
        end
        deleteIds << schedule.id
      }
    end
    unless deleteIds.nil?
      self.schedules.where.not(id: deleteIds).destroy_all
    end


    #sync schedules
    self.schedules.where(:agenda_type_id => AgendaType.competition_id).each do |schedule|
      player_ids = schedule.player_ids
      self.players.each do |player|
        bracket = player.brackets_enroll.where(:category_id => schedule.category_id)
        if bracket.present?
          player_ids << player.id
        end
      end
      schedule.player_ids = player_ids
    end
  end

  # sync all brackets of event
  def sync_brackes!(brackets)
    if brackets.kind_of? Array
      not_delete = []
      brackets.each do |bracket|
        #asing data of bracket
        data = {:event_bracket_id => bracket[:event_bracket_id], :age => bracket[:age],
                :lowest_skill => bracket[:lowest_skill], :highest_skill => bracket[:highest_skill],
                :quantity => bracket[:quantity], :young_age => bracket[:young_age], :old_age => bracket[:old_age]}
        parent_bracket = self.internal_brackets.where(id: bracket[:id]).update_or_create!(data)
        not_delete << parent_bracket.id
        if bracket[:brackets].kind_of? Array
          bracket[:brackets].each do |child_bracket|
            data = {:event_bracket_id => parent_bracket.id, :age => child_bracket[:age],
                    :lowest_skill => child_bracket[:lowest_skill], :highest_skill => child_bracket[:highest_skill],
                    :quantity => child_bracket[:quantity], :young_age => child_bracket[:young_age], :old_age => child_bracket[:old_age]}
            current_bracket = self.internal_brackets.where(id: child_bracket[:id]).update_or_create!(data)
            not_delete << current_bracket.id
          end
        end
      end
      self.internal_brackets.where.not(:id => not_delete).destroy_all
    end
  end

  def import_discount_personalizeds!(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      #row = Hash[[header, spreadsheet.row(i)].transpose]
      row = spreadsheet.row(i)
      email = row[0]
      code = row[1]
      discount = row[2]
      saved = self.discount_personalizeds.where(email: email).where(code: code).first
      if saved.present?
        saved.update!({discount: discount})
      else
        self.discount_personalizeds.create!({email: email, code: code, discount: discount})
      end
    end
  end

  #SEO URL for the event
  def public_url
    if self.event_url.nil? || self.visibility.to_s == "Private"
      return
    end
    if !url_valid?(self.event_url)
      errors.add(:event_url, "Url invalid")
    end
#Add to google search
    begin
      webmaster = Google::Apis::WebmastersV3::WebmastersService.new # Alias the module
      webmaster.key = "AIzaSyBAMhGfp9HfYai-3VKQ2mBoJi9lr9mKC8c"
      scope = 'https://www.googleapis.com/auth/webmasters'
      file = File.open(File.join(Rails.root, 'config', 'TopChamp-21f4c2e60b8f.json'))
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds({json_key_io: file, scope: scope})
      webmaster.authorization = authorizer
      response = webmaster.add_site(self.event_url)
    rescue Google::Apis::ClientError => e
      errors.add(e.to_json)
    end
#Add to bing search
    uri = URI.parse('https://ssl.bing.com/webmaster/api.svc/json/AddSite')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path + "?apikey=b2a64559583b44c8ba69f514a58876da", initheader = {'Content-Type' => 'application/json'})
    request.body = {siteUrl: self.event_url}.to_json

    http.request(request)

    response = http.request(request)
  end

  # Removr URL for SEO
  def remove_public_url
    if self.event_url.nil? || self.visibility.to_s == "Public"
      return
    end
    if !url_valid?(self.event_url)
      errors.add(:event_url, "Url invalid")
    end
#Add to google search
    begin
      webmaster = Google::Apis::WebmastersV3::WebmastersService.new # Alias the module
      webmaster.key = "AIzaSyBAMhGfp9HfYai-3VKQ2mBoJi9lr9mKC8c"
      scope = 'https://www.googleapis.com/auth/webmasters'
      file = File.open(File.join(Rails.root, 'config', 'TopChamp-21f4c2e60b8f.json'))
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds({json_key_io: file, scope: scope})
      webmaster.authorization = authorizer
      response = webmaster.delete_site(self.event_url)
    rescue Google::Apis::ClientError => e
      logger::info e.to_s
    rescue Google::Apis::ServerError => e
      logger::info e.to_s
    rescue Google::Apis::AuthorizationError => e
      logger::info e.to_s
    end
#Add to bing search
    uri = URI.parse('https://ssl.bing.com/webmaster/api.svc/json/RemoveSite')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path + "?apikey=b2a64559583b44c8ba69f514a58876da", initheader = {'Content-Type' => 'application/json'})
    request.body = {siteUrl: self.event_url}.to_json

    http.request(request)

    response = http.request(request)
  end

  swagger_schema :Event do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of event"
    end
    property :venue_id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of venue"
    end
    property :event_type_id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of  event type"
    end
    property :title do
      key :type, :string
      key :description, "Title string"
    end
    property :icon do
      key :type, :string
      key :description, "Uri to icon image\nExample. https://api.topchampsport.com/ + icon"
    end
    property :description do
      key :type, :string
      key :description, "Text to description"
    end
    property :start_date do
      key :type, :string
      key :format, :date
      key :description, "Start date of event\nformat 'YYYY-MM-DD'"
    end
    property :end_date do
      key :type, :string
      key :format, :date
      key :description, "End date of event\nformat 'YYYY-MM-DD'"
    end
    property :visibility do
      key :type, :string
      key :description, "Visibility of event\nExample. Private or Public"
    end
    property :requires_access_code do
      key :type, :boolean
      key :description, "Indicate if event require access code"
    end
    property :event_url do
      key :type, :string
      key :description, "Url to even"
    end
    property :is_event_sanctioned do
      key :type, :boolean
      key :description, "Indicate if event is sanctioned"
    end
    property :sanctions do
      key :type, :string
      key :description, "List of sanctions"
    end
    property :organization_name do
      key :type, :string
      key :description, "Name of my organization"
    end
    property :organization_url do
      key :type, :string
      key :description, "Url of my organization"
    end
    property :is_determine_later_venue do
      key :type, :boolean
      key :description, "Indicate if event later venue"
    end
    property :access_code do
      key :type, :string
      key :description, "Code to acces to a event"
    end
    property :status do
      key :type, :string
      key :description, "Status of event associated with event\nExample: Inactive or Active"
    end
    property :creator_user_id do
      key :type, :integer
      key :format, :int64
      key :description, "Creator user id associated with event"
    end
    property :valid_to_activate do
      key :type, :boolean
      key :description, "Indicate if is valid to activate"
    end
    property :reminder do
      key :type, :boolean
    end
    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
      key :description, "Sports associated with event"
    end
    property :regions do
      key :type, :array
      items do
        key :'$ref', :Region
      end
      key :description, "Regions associated with event"
    end

    property :schedules do
      key :type, :array
      items do
        key :'$ref', :EventSchedule
      end
      key :description, "Schedules associated with event"
    end
    property :venue do
      key :'$ref', :Venue
      key :description, "Venue associated with event"
    end

    property :event_type do
      key :'$ref', :EventType
      key :description, "Event type associated with event"
    end
    property :payment_information do
      key :'$ref', :EventPaymentInformation
      key :description, "Payment information associated with event"
    end

    property :payment_method do
      key :'$ref', :EventPaymentMethod
      key :description, "Payment method associated with event"
    end
    property :discount do
      key :'$ref', :EventDiscount
      key :description, "Discount associated with event"
    end
    property :discount_generals do
      key :'$ref', :EventDiscountGeneral
      key :description, "Discount general associated with event"
    end
    property :discount_personalizeds do
      key :'$ref', :EventDiscountPersonalized
      key :description, "Discount personalized associated with event"
    end

    property :tax do
      key :'$ref', :EventTax
      key :description, "Tax associated with event"
    end
    property :registration_rule do
      key :'$ref', :EventRegistrationRule
      key :description, "Registration rule associated with event"
    end
    property :contests do
      key :type, :array
      items do
        key :'$ref', :EventContest
      end
      key :description, "Contests associated with event"
    end
  end
  swagger_schema :EventInput do
    key :required, [:event_type_id, :title, :description]
    property :venue_id do
      key :type, :integer
      key :format, :int64
    end
    property :event_type_id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :icon do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :start_date do
      key :type, :string
      key :format, :date
    end
    property :end_date do
      key :type, :string
      key :format, :date
    end
    property :visibility do
      key :type, :string
    end
    property :requires_access_code do
      key :type, :boolean
    end
    property :event_url do
      key :type, :string
    end
    property :is_event_sanctioned do
      key :type, :boolean
    end
    property :sanctions do
      key :type, :string
    end
    property :organization_name do
      key :type, :string
    end
    property :organization_url do
      key :type, :string
    end
    property :is_determine_later_venue do
      key :type, :boolean
    end

    property :access_code do
      key :type, :string
    end
    property :sports do
      key :type, :array
      items do
        key :type, :integer
        key :format, :int64
      end
    end
    property :regions do
      key :type, :array
      items do
        key :type, :integer
        key :format, :int64
      end
    end
  end


  swagger_schema :EventSingle do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :venue_id do
      key :type, :integer
      key :format, :int64
    end
    property :event_type_id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :icon do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :start_date do
      key :type, :string
      key :format, :date
    end
    property :end_date do
      key :type, :string
      key :format, :date
    end
    property :visibility do
      key :type, :string
    end
    property :requires_access_code do
      key :type, :boolean
    end
    property :event_url do
      key :type, :string
    end
    property :is_event_sanctioned do
      key :type, :boolean
    end
    property :sanctions do
      key :type, :string
    end
    property :organization_name do
      key :type, :string
    end
    property :organization_url do
      key :type, :string
    end
    property :is_determine_later_venue do
      key :type, :boolean
    end

    property :access_code do
      key :type, :string
    end
    property :status do
      key :type, :string
    end
  end

  #Attach creator
  def save_creator!
    if Current.user and !self.creator_user_id.present?
      self.creator_user_id = Current.user.id
    end
  end

  #Determine if is complete for activate
  def valid_to_activate?
    self.title.present? && self.start_date.present?
  end

  def add_player(user_id, data)
    player = Player.where(user_id: user_id).where(event_id: self.id).first_or_create!
    player.sync_brackets!(data, true)
  end

  def only_for_men
    categories = self.internal_category_ids
    categories.included_in? Category.men_categories and !categories.included_in? Category.women_categories
  end

  def only_for_women
    categories = self.internal_category_ids
    categories.included_in? Category.women_categories and !categories.included_in? Category.men_categories
  end

  def available_brackets(data)
    brackets = []
    data.each do |bracket|
      current_bracket = EventContestCategoryBracketDetail.where(:event_id => self.id).where(:id => bracket[:event_bracket_id]).first
      if current_bracket.present?
        status = current_bracket.get_status
        if status == :enroll
          bracket[:enroll_status] = status
          brackets << bracket
        end
      end
    end
    brackets
  end

  def available_categories(user, player, contest_id, only_brackets = nil, include = false)
    response_data = []
    gender = user.gender
    age = user.age
    skill = user.skill_level
    skill = skill.nil? ? 99999999 : skill
    #subsrcibed categories
    in_categories_id = player.present? && include == false ? player.brackets.pluck(:category_id) : []
    #Validate gender
    genderCategories = []
    if gender == "Female"
      genderCategories = Category.women_categories
    elsif gender == "Male"
      genderCategories = Category.men_categories
    end
    event_categories = self.internal_category_ids(in_categories_id)
    categories = EventContestCategory.joins(contest: [:event]).merge(Event.where(:id => self.id)).where(:category_id => event_categories).where(:category_id => genderCategories)
    categories = categories.where(:event_contest_id => contest_id) if contest_id.present?
    #Validate categories
    if categories.length <= 0
      return []
    end
    except = []
    not_in = player.present? ? player.brackets.pluck(:event_bracket_id) : []
    force_in = player.present? ? player.brackets.pluck(:event_bracket_id) : []
    if include
      except = not_in
      not_in = []
    end
    #Validate skills
    categories.each do |category|
      category.filter_brackets = []
      allow_age_range = category.contest.sport_regulator.allow_age_range
      category.brackets.each do |bracket|
        bracket.filter_details = []
        bracket.details.not_in(not_in).each do |detail|
          if except.exclude?(detail.id)
            if !detail.for_show?
              not_in << detail.id
            end
          end
          unless detail.brackets.nil?
            detail.brackets.not_in(not_in).each do |detailchild|
              if except.exclude?(detail.id)
                if !detailchild.for_show?
                  not_in << detailchild.id
                end
              end
            end
          end
        end
        type = bracket.bracket_type
        case type
        when 'age'
          bracket.filter_details = bracket.details.only_filter(only_brackets).age_filter(age, allow_age_range, force_in).not_in(not_in).all
        when 'skill'
          bracket.filter_details = bracket.details.only_filter(only_brackets).skill_filter(skill, force_in).not_in(not_in).all
        when 'skill_age'
          bracket.details.only_filter(only_brackets).skill_filter(skill, force_in).not_in(not_in).each do |detail|
            detail.filter_brackets = detail.brackets.only_filter(only_brackets).age_filter(age, allow_age_range, force_in).not_in(not_in).all
            if detail.filter_brackets.length > 0
              bracket.filter_details << detail
            end
          end
        when 'age_skill'
          bracket.details.only_filter(only_brackets).age_filter(age, allow_age_range, force_in).not_in(not_in).each do |detail|
            detail.filter_brackets = detail.brackets.only_filter(only_brackets).skill_filter(skill, force_in).not_in(not_in).all
            if detail.filter_brackets.length > 0
              bracket.filter_details << detail
            end
          end
        end
        if include
          bracket.filter_details.map {|item|
            item.current = except.include?(item.id)
            item.partner = player.partner(item.id)
          }
        end
        if bracket.filter_details.length > 0
          category.filter_brackets << bracket
        end
      end
      if category.filter_brackets.length > 0
        response_data << category
      end
    end
    return response_data
  end

  def get_discount
    discount = nil
    discounts = self.discount
    total_players = self.players.count
    if discounts.present?
      if discounts.early_bird_date_start.present? and discounts.early_bird_date_end.present?
        start_date = discounts.early_bird_date_start.to_date
        end_date = discounts.early_bird_date_end.to_date
        if Date.today >= start_date and Date.today <= end_date and (discounts.early_bird_players > total_players or total_players == 0)
          discount = discounts.early_bird_registration
        end
      end
      if discounts.late_date_start.present? and discounts.late_date_end.present?
        start_date = discounts.late_date_start.to_date
        end_date = discounts.late_date_end.to_date
        if Date.today >= start_date and Date.today <= end_date and (discounts.late_players > total_players or total_players == 0)
          discount = discounts.late_registration
        end
      end
      if discounts.on_site_date_start.present? and discounts.on_site_date_end.present?
        start_date = discounts.on_site_date_start.to_date
        end_date = discounts.on_site_date_end.to_date
        if Date.today >= start_date and Date.today <= end_date and (discounts.on_site_players > total_players or total_players == 0)
          discount = discounts.on_site_registration
        end
      end
    end
    discount
  end


  def registration_fee
    discount = self.get_discount
    if discount.present?
      return discount
    else
      return self.payment_method.present? ? self.payment_method.enrollment_fee : 0
    end
    #return  enroll_fee - ((discount * enroll_fee) / 100)
  end

  #get if current user reminder event
  def reminder
    reminder = false
    user = Current.user
    unless user.nil?
      event_reminder = user.event_reminders.where(:event_id => self.id).first
      unless event_reminder.nil?
        reminder = event_reminder.reminder
      end
    end
    reminder
  end

  def send_notification
    event_reminders = self.event_reminders.where(:reminder => true).all
    event_reminders.each do |reminder|
      fcm = FCM.new(Rails.configuration.fcm_api_key)
      options = {data: {type: "event_reminder", id: self.id}, collapse_key: "updated_event", notification: {
          body: t("events.reminder_notification", event_title: self.title), sound: 'default'}}
      response = fcm.send_to_topic("user_chanel_#{reminder.user_id}", options)
    end
  end

  def internal_category_ids(ignore_ids = nil)
    query = self.contests.joins(:categories)
    unless ignore_ids.nil?
      query = query.merge(EventContestCategory.where.not(:category_id => ignore_ids))
    end
    query.pluck('event_contest_categories.category_id')
  end

  #get categories
  def categories
    categories = EventContestCategory.joins(:contest).merge(EventContest.where(:event_id => self.id)).pluck(:category_id)
    Category.where(:id => categories)
  end

  def send_email_to_admin
    CreateEventMailer.on_create(self, self.director).deliver
  end

  def calculate_prices(brackets, user, discount_code, is_applied = true)
    total = 0
    sub_total = 0
    amount = 0
    tax_total = 0
    discounts_total = 0
    tax_for_registration = 0
    tax_for_bracket = 0
    enroll_discount = 0
    enroll_total = 0
    enroll_amount = 0
    bracket_discount = 0
    bracket_total = 0
    bracket_amount = 0
    tax = nil
    is_paid_fee = self.is_paid_fee(user.id)
    enroll_fee = is_paid_fee ? 0 : self.registration_fee
    bracket_fee = self.payment_method.present? ? self.payment_method.bracket_fee : 0
    #Calculate total
    sub_total = enroll_fee
    brackets.each do |bracket|
      if bracket[:enroll_status] == :enroll
        sub_total += bracket_fee
      end
    end
    sub_total = sub_total.round(2)
    #set tax of event
    #todo review process
    if self.tax.present?
      if self.tax.is_percent
        tax = {:amount => ((self.tax.tax * sub_total) / 100).round(2), :name => "tax", :description => "Tax to enroll"}
        tax_for_registration = ((self.tax.tax * enroll_fee) / 100)
        tax_for_bracket = ((self.tax.tax * bracket_fee) / 100)
      else
        tax = {:amount => self.tax.tax, :name => "tax", :description => "Tax to enroll"}
        tax_for_registration = self.tax.tax / (1 + (brackets.length))
        tax_for_bracket = self.tax.tax / (1 + (brackets.length))
      end

    end
    enroll_total = (enroll_fee + tax_for_registration)
    bracket_total = ((bracket_fee * brackets.length) + tax_for_bracket)
    if tax.present?
      tax_total = tax[:amount]
    end
    total = sub_total + tax_total
    #apply discounts
    #event_discount = event.get_discount
    personalized_discount = self.discount_personalizeds.where(:code => discount_code).where(:email => user.email).first
    general_discount = self.discount_generals.where(:code => discount_code).first
    if personalized_discount.present?
      discounts_total = ((personalized_discount.discount * total) / 100)
      enroll_discount = ((personalized_discount.discount * enroll_total) / 100)
      bracket_discount = ((personalized_discount.discount * bracket_total) / 100)
    elsif general_discount.present? and general_discount.limited > general_discount.applied
      discounts_total = ((general_discount.discount * total) / 100)
      enroll_discount = ((general_discount.discount * enroll_total) / 100)
      bracket_discount = ((general_discount.discount * bracket_total) / 100)
      if is_applied
        general_discount.applied = general_discount.applied + 1
        general_discount.save!(:validate => false)
      end
    end
    amount = total - discounts_total
    enroll_amount = enroll_total - enroll_discount
    bracket_amount = bracket_total - bracket_discount


    if self.tax.present? and amount > 0
      if self.tax.is_percent
        tax = {:amount => ((self.tax.tax * (amount - tax_total)) / 100).round(2), :name => "tax", :description => "Tax to enroll"}
        tax_for_registration = ((self.tax.tax * (enroll_amount - tax_for_registration)) / 100)
        tax_for_bracket = ((self.tax.tax * (bracket_amount - tax_for_bracket)) / 100)
      end
    else
      tax = {:amount => 0, :name => "tax", :description => "Tax to enroll"}
      tax_for_registration = 0
      tax_for_bracket = 0
    end
=begin
    if tax.present?
      tax_total = tax[:amount]
    end
=end
    # amount = amount - 0.001
    JSON.parse({amount: amount.round(2), enroll_amount: enroll_amount.round(2), bracket_amount: bracket_amount.round(2), is_paid_fee: is_paid_fee,
                total: total.round(2), sub_total: sub_total.round(2), tax_total: tax_total.round(2), discounts_total: discounts_total.round(2),
                tax_for_registration: tax_for_registration.round(2), tax_for_bracket: tax_for_bracket.round(2), enroll_discount: enroll_discount.round(2),
                enroll_total: enroll_total.round(2), bracket_discount: bracket_discount.round(2), tax: tax,
                bracket_total: bracket_total.round(2), enroll_fee: enroll_fee.round(2), bracket_fee: bracket_fee.round(2)}.to_json, object_class: OpenStruct)
  end


  def is_paid_fee(user_id)
    Payments::PaymentTransaction.where(event_id: self.id).where(user_id: user_id).joins(:details)
        .merge(Payments::PaymentTransactionDetail.where(type_payment: 'event_enroll')).count > 0
  end

  private

  #validate a url
  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end

  #Validate image dimensions
  def check_dimensions
    required_width = 300
    required_height = 300
    temp_file = icon.queued_for_write[:original]
    unless temp_file.nil?
      dimensions = Paperclip::Geometry.from_file(temp_file.path)
      # add errors to show
      errors.add(:image, "Maximun width must be #{required_width}px") unless dimensions.width <= required_width
      errors.add(:image, "Maximun height must be #{required_height}px") unless dimensions.height <= required_height
    end
  end
end
