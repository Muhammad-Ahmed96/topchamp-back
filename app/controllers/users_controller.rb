class UsersController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive]
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
        key :description, 'Column to order'
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
    role = params[:role].strip unless params[:role].nil?
    column = params[:column].nil? ? 'first_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    status = params[:status]
    paginate User.unscoped.my_order(column, direction).in_role(role).search(search).is_status(status), per_page: 50, root: :data
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

  def show
    authorize User
    json_response_data(@resource)
  end

  def update
    authorize User
    if !params[:sports].nil?
      @resource.sport_ids = params[:sports]
    end
    if !params[:contact_information].nil?
      @resource.create_contact_information! contact_information_params
    end
    if !params[:billing_address].nil?
      @resource.create_billing_address! billing_address_params
    end
    if !params[:shipping_address].nil?
      @resource.create_shipping_address! shipping_address_params
    end
    if !params[:association_information].nil?
      @resource.create_association_information! association_information_params
    end

    if !params[:medical_information].nil?
      @resource.create_medical_information! medical_information_params
    end
    @resource.update!(resource_params)
    json_response_success(t("edited_success", model: User.model_name.human), true)
  end

  def destroy
    authorize User
    @resource.destroy
    json_response_success(t("deleted_success", model: User.model_name.human), true)
  end

  def activate
    authorize User
    @resource.status = :Active
    @resource.save
    json_response_success(t("activated_success", model: User.model_name.human), true)
  end

  def inactive
    authorize User
    @resource.status = :Inactive
    @resource.save
    json_response_success(t("inactivated_success", model: User.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:first_name, :middle_initial, :last_name, :badge_name, :birth_date, :email, :role, :gender,
                  :profile)
  end

  def contact_information_params
    # whitelist params
    params.require(:contact_information).permit(:cell_phone, :country_code_phone, :alternative_email, :address_line_1, :address_line_2,
                                                :postal_code, :state, :city, :work_phone, :emergency_contact_full_name,
                                                :emergency_contact_country_code_phone, :emergency_contact_phone)
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
    @resource = User.find(params[:id])
  end
end
