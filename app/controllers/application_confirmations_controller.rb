class ApplicationConfirmationsController < ApplicationController
  include Swagger::Blocks
  swagger_path '/application_confirmations' do
    operation :post do
      key :summary, 'Confirmation a account'
      key :description, 'Confirms the users entered the correct pin number.'
      key :operationId, 'accountCreate'
      key :produces, ['application/json',]
      key :tags, ['confirmations']
      parameter do
        key :name, :pin
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
    set_resource_by_email
    unless @resource.present?
      #return json_response_error([t("devise_token_auth.passwords.user_not_found")], 422)
      return json_response_error(t("devise_token_auth.passwords.user_not_found"), 422)
    end
    if @resource.pin == pin_params[:pin]
      @resource.confirm
      if @resource.confirmed?
        # email auth has been bypassed, authenticate user
        @client_id, @token = @resource.create_token
        @resource.pin = nil
        @resource.status = :Active
        @resource.role = :Director
        @resource.save!
        update_auth_header
        json_response_serializer(@resource, UserSerializer)
      else
        #json_response_error([t("confirmations.not_confirm")], 422)
        json_response_error(t("confirmations.not_confirm"), 422)
      end
    else
      #json_response_error([t("confirmations.invalid_pin")], 422)
      json_response_error(t("confirmations.invalid_pin"), 422)
    end
  end
  swagger_path '/application_confirmations/resend_pin' do
    operation :post do
      key :summary, 'Resend confirmation a account'
      key :description, 'Confirmation'
      key :operationId, 'accountResendPin'
      key :produces, ['application/json',]
      key :tags, ['confirmations']
      parameter do
        key :name, :email
        key :in, :body
        key :required, true
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
  def resend_pin
    set_resource_by_email
    unless @resource.present?
      return json_response_error([t("devise_token_auth.passwords.user_not_found")], 422)
    end
    unless @resource.confirmed?
      @resource.set_random_pin!
      # user will require email authentication
      @resource.send_confirmation_instructions({
                                                   client_config: params[:config_name],
                                                   redirect_url: @redirect_url
                                               })
      json_response_success(t("devise.confirmations.send_instructions"), true)
    else
      json_response_error([t("errors.messages.already_confirmed")], 422)
    end
  end

  protected

  def pin_params
    # whitelist params
    params.permit(:pin, :email)
  end

  def set_resource
    @resource = User.find_by_pin(pin_params[:pin])
  end
  def set_resource_by_email
    @resource = User.find_by_uid(pin_params[:email])
  end

  def resource_errors
    return @resource.errors
  end
end
