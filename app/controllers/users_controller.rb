class UsersController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive, :profile]
  before_action :authenticate_user!
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
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :User
            end
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
    if column.to_s == "state"  || column.to_s == "city"
      column_contact_information = column
      column = nil
    end
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end
    paginate User.my_order(column, direction).search(search).in_role(role).birth_date_in(birth_date)
                 .in_status(status).first_name_like(first_name).last_name_like(last_name).gender_like(gender)
                 .email_like(email).last_sign_in_at_like(last_sign_in_at).state_like(state).city_like(city)
                 .sport_in(sport_id).contact_information_order(column_contact_information, direction).sports_order(column_sports, direction), per_page: 50, root: :data
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
    authorize User
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
    authorize User
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
    authorize User
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
    authorize User
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
    @user.save
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
    @user.save
    json_response_success(t("inactivated_success", model: User.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:first_name, :middle_initial, :last_name, :badge_name, :birth_date, :email, :role, :gender,
                  :profile)
  end

  def resource_profile_params
    # whitelist params
    params.permit(:profile)
  end

  def contact_information_params
    # whitelist params
    params.require(:contact_information).permit(:cell_phone, :country_code_phone, :alternative_email, :address_line_1, :address_line_2,
                                                :postal_code, :state, :city,:country_code_work_phone , :work_phone, :emergency_contact_full_name,
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

  def set_resource
    @user = User.find(params[:id])
  end
end
