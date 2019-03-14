require 'action_view'
include ActionView::Helpers::NumberHelper
class UsersController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!, except: [:sing_up_information, :my_events]
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive, :profile, :sing_up_information]
  around_action :transactions_filter, only: [:update, :create]
# Update password
  swagger_path '/users' do
    operation :get do
      key :summary, 'Get users list'
      key :description, 'User Catalog'
      key :operationId, 'usersIndex'
      key :produces, ['application/json',]
      key :tags, ['users']
      parameter do
        key :name, :search
        key :in, :query
        key :description, 'Keyword to search'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :role
        key :in, :query
        key :description, 'Filter role'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :column
        key :in, :query
        key :description, 'Column to order special "sport_name" parameter for sports order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :direction
        key :in, :query
        key :description, 'Direction to order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :status
        key :in, :query
        key :description, 'Status filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :first_name
        key :in, :query
        key :description, 'First name filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :query
        key :description, 'Last name filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :gender
        key :in, :query
        key :description, 'Gender filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :query
        key :description, 'Email filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :last_sign_in_at
        key :in, :query
        key :description, 'Last sign filter format(Y-m-d)'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :query
        key :description, 'City filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :birth_date
        key :in, :query
        key :description, 'Birth date format(Y-m-d)'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :sport_id
        key :in, :query
        key :description, 'Id of te sport filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'User Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :User
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', PaginateModel
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def index
    authorize User
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'first_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    status = params[:status]
    role = params[:role]
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = params[:gender]
    email = params[:email]
    last_sign_in_at = params[:last_sign_in_at]
    state = params[:state]
    city = params[:city]
    sport_id = params[:sport_id]
    birth_date = params[:birth_date]
    column_contact_information = nil
    column_sports = nil
    if column.to_s == "state" || column.to_s == "city"
      column_contact_information = column
      column = nil
    end
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end

    users = User.my_order(column, direction).search(search).in_role(role).birth_date_in(birth_date)
                .in_status(status).first_name_like(first_name).last_name_like(last_name).gender_like(gender)
                .email_like(email).last_sign_in_at_like(last_sign_in_at).state_like(state).city_like(city)
                .sport_in(sport_id).contact_information_order(column_contact_information, direction).sports_order(column_sports, direction)
    if paginate.to_s == "0"
      json_response_serializer_collection(users.all, UserSerializer)
    else
      paginate users, per_page: 50, root: :data
    end
  end

  swagger_path '/users' do
    operation :post do
      key :summary, 'Create a user'
      key :description, 'User Catalog'
      key :operationId, 'usersCreate'
      key :produces, ['application/json',]
      key :tags, ['users']
      parameter do
        key :name, :first_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :gender
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :badge_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :birth_date
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :middle_initial
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :role
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :profile
        key :in, :body
        key :required, false
        key :type, :file
      end
      parameter do
        key :name, :sports
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      parameter do
        key :name, :is_receive_text
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :contact_information
        key :in, :body
        key :description, 'Contact information'
        schema do
          key :'$ref', :ContactInformationInput
        end
      end
      parameter do
        key :name, :billing_address
        key :in, :body
        key :description, 'Billing address'
        schema do
          key :'$ref', :BillingAddressInput
        end
      end
      parameter do
        key :name, :shipping_address
        key :in, :body
        key :description, 'Shipping address'
        schema do
          key :'$ref', :ShippingAddressInput
        end
      end
      parameter do
        key :name, :association_information
        key :in, :body
        key :description, 'Association information'
        schema do
          key :'$ref', :AssociationInformationInput
        end
      end
      parameter do
        key :name, :medical_information
        key :in, :body
        key :description, 'Medical information'
        schema do
          key :'$ref', :MedicalInformationInput
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def create
    authorize User
    resource = User.create!(resource_params)
    if !params[:sports].nil?
      resource.sport_ids = params[:sports]
    end
    if !params[:contact_information].nil?
      resource.create_contact_information! contact_information_params
    end
    if !params[:billing_address].nil?
      resource.create_billing_address! billing_address_params
    end
    if !params[:shipping_address].nil?
      resource.create_shipping_address! shipping_address_params
    end
    if !params[:association_information].nil?
      resource.create_association_information! association_information_params
    end
    if !params[:medical_information].nil?
      resource.create_medical_information! medical_information_params
    end
    resource.role = :Director
    resource.save
    resource.sync_invitation
    json_response_success(t("created_success", model: User.model_name.human), true)
  end

  swagger_path '/users/:id' do
    operation :get do
      key :summary, 'Show a user'
      key :description, 'User Catalog'
      key :operationId, 'usersShow'
      key :produces, ['application/json',]
      key :tags, ['users']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :User
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def show
    authorize @user
    json_response_serializer(@user, UserSerializer)
  end

  swagger_path '/users/:id' do
    operation :put do
      key :summary, 'Update a user'
      key :description, 'User Catalog'
      key :operationId, 'usersUpdate'
      key :produces, ['application/json',]
      key :tags, ['users']
      parameter do
        key :name, :first_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :gender
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :badge_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :birth_date
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :middle_initial
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :role
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :profile
        key :in, :body
        key :required, false
        key :type, :file
      end
      parameter do
        key :name, :sports
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      parameter do
        key :name, :is_receive_text
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :contact_information
        key :in, :body
        key :description, 'Contact information'
        schema do
          key :'$ref', :ContactInformationInput
        end
      end
      parameter do
        key :name, :billing_address
        key :in, :body
        key :description, 'Billing address'
        schema do
          key :'$ref', :BillingAddressInput
        end
      end
      parameter do
        key :name, :shipping_address
        key :in, :body
        key :description, 'Shipping address'
        schema do
          key :'$ref', :ShippingAddressInput
        end
      end
      parameter do
        key :name, :association_information
        key :in, :body
        key :description, 'Association information'
        schema do
          key :'$ref', :AssociationInformationInput
        end
      end
      parameter do
        key :name, :medical_information
        key :in, :body
        key :description, 'Medical information'
        schema do
          key :'$ref', :MedicalInformationInput
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def update
    authorize @user
    if !params[:sports].nil?
      @user.sport_ids = params[:sports]
    end
    if !params[:contact_information].nil?
      @user.create_contact_information! contact_information_params
    end
    if !params[:billing_address].nil?
      @user.create_billing_address! billing_address_params
    end
    if !params[:shipping_address].nil?
      @user.create_shipping_address! shipping_address_params
    end
    if !params[:association_information].nil?
      @user.create_association_information! association_information_params
    end

    if !params[:medical_information].nil?
      @user.create_medical_information! medical_information_params
    end
    @user.update!(resource_params)
    json_response_success(t("edited_success", model: User.model_name.human), true)
  end

  swagger_path '/users/:id/profile' do
    operation :put do
      key :summary, 'Update profile picture to a user'
      key :description, 'User Catalog'
      key :operationId, 'usersUpdateProfile'
      key :produces, ['application/json',]
      key :tags, ['users']
      parameter do
        key :name, :profile
        key :in, :body
        key :required, false
        key :type, :file
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def profile
    authorize @user
    @user.update!(resource_profile_params)
    json_response_success(t("edited_success", model: User.model_name.human), true)
  end

  swagger_path '/users/:id' do
    operation :delete do
      key :summary, 'Delete a user'
      key :description, 'User Catalog'
      key :operationId, 'usersDelete'
      key :produces, ['application/json',]
      key :tags, ['users']
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def destroy
    authorize @user
    @user.destroy
    json_response_success(t("deleted_success", model: User.model_name.human), true)
  end

  swagger_path '/users/:id/activate' do
    operation :put do
      key :summary, 'Activate a user'
      key :description, 'User Catalog'
      key :operationId, 'usersActivate'
      key :produces, ['application/json',]
      key :tags, ['users']
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def activate
    authorize User
    @user.status = :Active
    @user.save!(:validate => false)
    json_response_success(t("activated_success", model: User.model_name.human), true)
  end

  swagger_path '/users/:id/inactive' do
    operation :put do
      key :summary, 'Inactive a user'
      key :description, 'User Catalog'
      key :operationId, 'usersInactive'
      key :produces, ['application/json',]
      key :tags, ['users']
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def inactive
    authorize User
    @user.status = :Inactive
    @user.tokens = nil
    @user.save!(:validate => false)
    json_response_success(t("inactivated_success", model: User.model_name.human), true)
  end

  swagger_path '/users/current_enrolls' do
    operation :get do
      key :summary, 'Enrolls of user'
      key :description, 'User Catalog'
      key :operationId, 'usersCurrentEnroll'
      key :produces, ['application/json',]
      key :tags, ['users']
      response 200 do
        key :name, :data
        key :description, 'enrolls'
        schema do
          key :type, :array
          items do
            key :'$ref', :Event
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def current_enrolls
    events = Event.joins(:players).merge(Player.where(:user_id => @resource.id)).all
    json_response_serializer_collection(events, EventWithDirectorSerializer)
  end

  swagger_path '/users/:id/sing_up_information' do
    operation :put do
      key :summary, 'Sing up information of user'
      key :description, 'User Catalog'
      key :operationId, 'usersSingUpInformation'
      key :produces, ['application/json',]
      key :tags, ['users']
      parameter do
        key :name, :postal_code
        key :in, :body
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :body
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :body
        key :type, :string
      end
      parameter do
        key :name, :country
        key :in, :body
        key :type, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def sing_up_information
    if @user.active_for_authentication?
      return json_response_error([t("is_already_active")], 422)
    end
    contact_information = @user.contact_information
    if contact_information.present?
      contact_information.update! sing_up_informations_params
    else
      @user.create_contact_information! sing_up_informations_params
    end

    json_response_serializer(@user, UserSingleSerializer)
  end

  def my_events
    eventsId = Player.where(:user_id => @resource.id).pluck(:event_id)
    events = Event.where(:id => eventsId)
    json_response_serializer_collection(events, EventSingleSerializer)
  end

  def import_users
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    event = Event.find(params[:event])
    contest = params[:contest]
    category = params[:category]
    bracket = params[:bracket]
    fees = EventFee.first
    now = Date.today
    last = nil
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      email = row["Email"].gsub(/\s+/, "").downcase
      if email.blank?
        email = Faker::Internet.email
      end
      item = User.find_by_email(email) || User.new
      item.uid  = email
      item.email  = email
      item.first_name  = row['First Name']
      item.last_name  = row['Last Name']
      item.gender  = row['Sex'] === 'F' ? 'Female' : row['Sex'] === 'M' ? 'Male' : nil
      birth = Date.strptime(row['Birthdate'], '%m/%d/%Y') rescue nil
      item.birth_date  = birth.nil? ? birth : Date.strptime(row['Birthdate'], '%m/%d/%Y')
      item.status = :Active
      item.confirm
      item.role = "Member"
      item.save!
      data = { :raking => row['Skill']}
      item.create_association_information! data

      #invite
      if last.present?
        data = {:event_id => event.id, :email => email, :url => nil, attendee_types: [AttendeeType.player_id]}
        invitation = Invitation.get_invitation(data, last, 'partner_mixed')
        invitation.status = :accepted
        invitation.save!
        saved = invitation.brackets.where(:event_bracket_id => bracket, :category_id => category).first
        if saved.nil?
          invitation.brackets.create!({:event_bracket_id => bracket, :category_id => category, :accepted => true})
        end
        last = nil
      else
        last = item.id
      end

      self.subscribe(event, item, fees, [{:category_id => category, :contest_id => contest, :event_bracket_id => bracket}])
    end
    return json_response_success(t("success"), true)
  end


  def set_teams
    spreadsheet = open_spreadsheet
    event = Event.find(params[:event])
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      email = row["Email"].gsub(/\s+/, "").downcase
      item = User.find_by_email(email)
      unless item.nil?
        player = Player.where(user_id: item.id).where(event_id: event.id).first
        unless player.nil?
          player.set_teams false
        end
      end
    end
    return json_response_success(t("success"), true)
  end


  def open_spreadsheet
    file = params[:file]
    case File.extname(file.original_filename)
    when ".csv" then
      Csv.new(file.path, nil, :ignore)
    when ".xls" then
      Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then
      Roo::Excelx.new(file.path)
    else
      raise "Unknown file type: #{file.original_filename}"
    end
  end


  def subscribe(event, user, fees, bracketsParams)
    #only for test
    brackets = event.available_brackets(bracketsParams)
    if brackets.length <= 0
      return false
    end
    discount_code = '0000'
    config = Payments::ItemsConfig.get_bracket
    items = []
    amount = 0
    tax_total = 0
    discounts_total = 0
    tax_for_registration = 0
    tax_for_bracket = 0
    enroll_fee = event.registration_fee
    bracket_fee = event.payment_method.present? ? event.payment_method.bracket_fee : 0
    #aply discounts
    #event_discount = event.get_discount
    personalized_discount = event.discount_personalizeds.where(:code => discount_code).where(:email => user.email).first
    general_discount = event.discount_generals.where(:code => discount_code).first

    #enroll_fee = enroll_fee - ((event_discount * enroll_fee) / 100)
    #todo discount
    #bracket_fee = bracket_fee - ((event_discount * bracket_fee) / 100)

    if personalized_discount.present?
      discounts_total = ((personalized_discount.discount * enroll_fee) / 100)
      enroll_fee = enroll_fee - discounts_total
      # bracket_fee = bracket_fee - ((personalized_discount.discount * bracket_fee) / 100)
    elsif general_discount.present? and general_discount.limited > general_discount.applied
      discounts_total = ((general_discount.discount * enroll_fee) / 100)
      enroll_fee = enroll_fee - discounts_total
      #bracket_fee = bracket_fee - ((general_discount.discount * bracket_fee) / 100)
      general_discount.applied = general_discount.applied + 1
      general_discount.save!(:validate => false)
    end
    #only for test
    #enroll_fee = 1
    #bracket_fee = 1
    #first item event fee
    item = {id: "Fee-#{event.id}", name: "Enroll fee", description: "Enroll fee", quantity: 1, unit_price: enroll_fee,
            taxable: true}
    items << item
    brackets.each do |bracket|
      if bracket[:enroll_status] == :enroll
        item = {id: "#{config[:id]}-#{bracket[:event_bracket_id]}", name: "Bracket-#{bracket[:event_bracket_id]}", description: "Subscribe to Bracket-#{bracket[:event_bracket_id]}", quantity: 1, unit_price: bracket_fee,
                taxable: true}
        amount += bracket_fee
        items << item
      end
    end
    amount += enroll_fee
    #set tax of event
    tax = nil
    #todo review process
    if event.tax.present?
      if event.tax.is_percent
        tax = {:amount => ((event.tax.tax * amount) / 100), :name => "tax", :description => "Tax to enroll"}
        tax_for_registration = ((event.tax.tax * enroll_fee) / 100)
        tax_for_bracket = ((event.tax.tax * bracket_fee) / 100)
      else
        tax = {:amount => event.tax.tax, :name => "tax", :description => "Tax to enroll"}
        tax_for_registration = event.tax.tax / (1 + (brackets.length))
        tax_for_bracket = event.tax.tax / (1 + (brackets.length))
      end

    end
    if tax.present?
      tax_total = tax[:amount]
      amount = amount + tax_total
    end
     response =  JSON.parse({transactionResponse: {transId: '000'}}.to_json, object_class: OpenStruct)
    #save bracket on player
    player = Player.where(user_id: user.id).where(event_id: event.id).first_or_create!
    player.sync_brackets!(brackets, true)
    app_fee = 0.0
    amount = amount.to_f
    if fees.present?
      if fees.is_transaction_fee_percent
        app_fee =  ((fees.transaction_fee * amount) / 100)
      else
        app_fee = fees.transaction_fee
      end
    end
    authorize_fee =  ((Rails.configuration.authorize[:transaction_fee] * amount) / 100) + Rails.configuration.authorize[:extra_charges]
    account = amount - authorize_fee

    director_receipt = amount - (authorize_fee + app_fee)

    paymentTransaction = player.payment_transactions.create!(:payment_transaction_id => response.transactionResponse.transId, :user_id => user.id,
                                                             :amount => amount, :tax => number_with_precision(tax_total, precision: 2), :description => "TransactionForSubscribe",
                                                             :event_id => player.event_id, :discount => discounts_total, :authorize_fee => authorize_fee, :app_fee => app_fee,
                                                             :director_receipt => director_receipt, :account => account)
    brackets.each do |item|
      paymentTransaction.details.create!({:amount => bracket_fee, :tax => number_with_precision(tax_for_bracket, precision: 2),
                                          :event_bracket_id => item[:event_bracket_id], :category_id => item[:category_id],
                                          :event_id => player.event_id, :type_payment => "bracket", :contest_id => item[:contest_id]})
    end
    paymentTransaction.details.create!({:amount => enroll_fee, :tax => number_with_precision(tax_for_registration, precision: 2),
                                        :event_id => player.event_id, :type_payment => "event_enroll", :attendee_type_id => AttendeeType.player_id})

    player.brackets.where(:enroll_status => :enroll).where(:payment_transaction_id => nil)
        .where(:event_bracket_id => brackets.pluck(:event_bracket_id))
        .update(:payment_transaction_id => response.transactionResponse.transId)
    player.set_teams false
  end

  private

  def resource_params
    # whitelist params
    params.permit(:first_name, :middle_initial, :last_name, :badge_name, :birth_date, :email, :role, :gender,
                  :profile, :is_receive_text)
  end

  def resource_profile_params
    # whitelist params
    params.permit(:profile)
  end

  def contact_information_params
    # whitelist params
    params.require(:contact_information).permit(:cell_phone, :country_code_phone, :alternative_email, :address_line_1, :address_line_2,
                                                :postal_code, :state, :city, :country_code_work_phone, :work_phone, :emergency_contact_full_name,
                                                :emergency_contact_country_code_phone, :emergency_contact_phone, :is_receive_text)
  end

  def billing_address_params
    # whitelist params
    params.require(:billing_address).permit(:address_line_1, :address_line_2, :postal_code, :city, :state)
  end

  def shipping_address_params
    # whitelist params
    params.require(:shipping_address).permit(:contact_name, :address_line_1, :address_line_2, :postal_code, :city, :state)
  end

  def association_information_params
    # whitelist params
    params.require(:association_information).permit(:membership_type, :membership_id, :raking, :affiliation, :certification, :company)
  end

  def medical_information_params
    # whitelist params
    params.require(:medical_information).permit(:insurance_provider, :insurance_policy_number, :group_id, :primary_physician_full_name, :primary_physician_country_code_phone,
                                                :primary_physician_phone, :dietary_restrictions, :allergies)
  end

  def sing_up_informations_params
    params.permit(:postal_code, :state, :city, :country)
  end

  def set_resource
    @user = User.find(params[:id])
  end
end
