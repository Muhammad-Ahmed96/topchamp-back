require 'google/apis/webmasters_v3'
require 'google/apis/translate_v2'
require 'google/api_client/client_secrets'
require 'json'
require "uri"
require "net/http"

class Event < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_and_belongs_to_many :sports
  has_and_belongs_to_many :regions
  has_and_belongs_to_many :internal_categories, :join_table => "categories_events", class_name: "Category"
  has_many :categories, :class_name => "CategoriesEvent"
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
  has_many :agendas, class_name: 'EventAgenda'
  #has_one :rule, class_name: 'EventRule'
  belongs_to :sport_regulator, optional: true
  belongs_to :elimination_format, optional: true


  has_one :payment_transaction, class_name: 'Payments::PaymentTransaction', :as => :transactionable

  has_many :brackets, -> {only_parent}, class_name: "EventBracket"
  has_many :internal_brackets, class_name: "EventBracket"


  belongs_to :scoring_option_match_1, foreign_key: "scoring_option_match_1_id", class_name: "ScoringOption", optional: true
  belongs_to :scoring_option_match_2, foreign_key: "scoring_option_match_2_id", class_name: "ScoringOption", optional: true


  validates :bracket_by, inclusion: {in: Bracket.collection.keys.map(&:to_s)}, :allow_nil => true
  accepts_nested_attributes_for :discount_generals
  accepts_nested_attributes_for :discount_personalizeds

  after_initialize :save_creator!, if: :new_record?

  has_attached_file :icon, :path => ":rails_root/public/images/event_icons/:to_param/:style/:basename.:extension",
                    :url => "/images/event_icons/:to_param/:style/:basename.:extension",
                    styles: {medium: "100X100>", thumb: "50x50>"}, default_url: "/assets/event/:style/default_noevent.png"
  validates_attachment :icon
  validate :check_dimensions
  validates_with AttachmentSizeValidator, attributes: :icon, less_than: 2.megabytes
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/

  validates :title, presence: true
  validates :event_url, uniqueness: true, url: true, :allow_nil => true
  #validates :event_type_id, presence: true
  validates :description, length: {maximum: 1000}
  #validates :visibility, inclusion: {in: Visibility.collection.keys.map(&:to_s)}, :allow_nil => true


  scope :in_status, lambda {|status| where status: status if status.present?}
  scope :only_directors, lambda {|id| joins(participants: [:attendee_types]).merge(Participant.where :user_id => id).merge(AttendeeType.where :id => AttendeeType.director_id)if id.present?}
  scope :in_visibility, lambda {|data| where visibility: data if data.present?}
  scope :title_like, lambda {|search| where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :start_date_like, lambda {|search| where("LOWER(concat(trim(to_char(start_date, 'Month')),',',to_char(start_date, ' DD, YYYY'))) LIKE LOWER(?)", "%#{search}%") if search.present?}


  scope :state_like, lambda {|search| joins(:venue).merge(Venue.where ["LOWER(state) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :city_like, lambda {|search| joins(:venue).merge(Venue.where ["LOWER(city) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :venue_order, lambda {|column, direction = "desc"| includes(:venue).order("venues.#{column} #{direction}") if column.present?}

  scope :sport_in, lambda {|search| joins(:sports).merge(Sport.where id: search) if search.present?}
  scope :sports_order, lambda {|column, direction = "desc"| includes(:sports).order("sports.#{column} #{direction}") if column.present?}

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


  def sync_agendas!(data)
    deleteIds = []
    if data.present?
      event_agenda = nil
      data.each {|agenda|
        if agenda[:id].present?
          event_agenda = self.agendas.where(id: agenda[:id]).first
          if event_agenda.present?
            event_agenda.update! agenda
          else
            agenda[:id] = nil
            event_agenda = self.agendas.create! agenda
          end
        else
          event_agenda = self.agendas.create! agenda
        end
        deleteIds << event_agenda.id
      }
    end
    unless deleteIds.nil?
      self.agendas.where.not(id: deleteIds).destroy_all
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
      key :type, :date
    end
    property :end_date do
      key :type, :date
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
    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
    end
    property :event_type do
      key :'$ref', :EventType
    end
    property :venue do
      key :'$ref', :Venue
    end
    property :regions do
      key :type, :array
      items do
        key :'$ref', :Region
      end
    end

    property :payment_information do
      key :'$ref', :EventPaymentInformation
    end

    property :payment_method do
      key :'$ref', :EventPaymentMethod
    end
    property :discount do
      key :'$ref', :EventDiscount
    end
    property :discount_generals do
      key :'$ref', :EventDiscountGeneral
    end
    property :discount_personalizeds do
      key :'$ref', :EventDiscountPersonalized
    end

    property :tax do
      key :'$ref', :EventTax
    end
    property :registration_rule do
      key :'$ref', :EventRegistrationRule
    end
    property :brackets do
      key :type, :array
      items do
        key :'$ref', :EventBracket
      end
    end
    property :sport_regulator_id do
      key :type, :integer
      key :format, :int64
    end
    property :elimination_format_id do
      key :type, :integer
      key :format, :int64
    end
    property :bracket_by do
      key :type, :string
    end
    property :scoring_option_match_1_id do
      key :type, :integer
      key :format, :int64
    end
    property :scoring_option_match_2_id do
      key :type, :integer
      key :format, :int64
    end

    property :sport_regulator do
      key :type, :array
      items do
        key :'$ref', :SportRegulator
      end
    end
    property :elimination_format do
      key :type, :array
      items do
        key :'$ref', :EliminationFormat
      end
    end
    property :scoring_option_match_1 do
      key :type, :array
      items do
        key :'$ref', :ScoringOption
      end
    end
    property :scoring_option_match_1 do
      key :type, :array
      items do
        key :'$ref', :ScoringOption
      end
    end

    property :awards_for do
      key :type, :string
    end
    property :awards_through do
      key :type, :string
    end
    property :awards_plus do
      key :type, :string
    end
    property :agendas do
      key :type, :array
      items do
        key :'$ref', :EventAgenda
      end
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
      key :type, :date
    end
    property :end_date do
      key :type, :date
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
      key :type, :date
    end
    property :end_date do
      key :type, :date
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
    if Current.user
      self.creator_user_id = Current.user.id
    end
  end

  #Determine if is complete for activate
  def valid_to_activate?
    self.title.present? && self.start_date.present?
  end

  def add_player(user_id, data)
    player = Player.where(user_id: user_id).where(event_id: self.id).first_or_create!
    player.sync_brackets! data
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
      current_bracket = EventBracket.where(:event_id => self.id).where(:id => bracket[:event_bracket_id]).first
      category = self.internal_categories.where(:id => bracket[:category_id]).count
      allow_wait_list = self.registration_rule.present? ? self.registration_rule.allow_wait_list : false
      if current_bracket.present? and category > 0
        status = current_bracket.get_status(bracket[:category_id])
        if status == :enroll or (status == :waiting_list and allow_wait_list)
          bracket[:enroll_status] = status
          brackets << bracket
        end
      end
    end
    brackets
  end

  def get_discount
    discount = 0
    discounts = self.discount
    total_players = self.players.count
    if discounts.present?
      if discounts.early_bird_date_start.present? and discounts.early_bird_date_end.present?
        start_date = discounts.early_bird_date_start.to_date
        end_date = discounts.early_bird_date_end.to_date
        if Date.today >= start_date and Date.today <=end_date and (discounts.early_bird_players < total_players or total_players == 0)
          discount = discounts.early_bird_registration
        end
      end
      if discounts.late_date_start.present? and discounts.late_date_end.present?
        start_date = discounts.late_date_start.to_date
        end_date = discounts.late_date_end.to_date
        if Date.today >= start_date and Date.today <=end_date and (discounts.late_players < total_players or total_players == 0)
          discount = discounts.late_registration
        end
      end
      if discounts.on_site_date_start.present? and discounts.on_site_date_end.present?
        start_date = discounts.on_site_date_start.to_date
        end_date = discounts.on_site_date_end.to_date
        if Date.today >= start_date and Date.today <=end_date and (discounts.on_site_players < total_players or total_players == 0)
          discount = discounts.on_site_registration
        end
      end
    end
    discount
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
