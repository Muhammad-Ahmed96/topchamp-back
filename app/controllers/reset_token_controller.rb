class ResetTokenController < ApplicationController
  include Swagger::Blocks
  # Log in process
  swagger_path '/check_reset_token/:reset_password_token' do
    operation :get do
      key :summary, 'Validation of reset password token'
      key :description, 'Requires reset password token.'
      key :operationId, 'resetPasswordToken'
      key :produces, ['application/json',]
      key :tags, ['Validation reset password token']
      parameter do
        key :name, :reset_password_token
        key :in, :path
        key :description, 'Reset token'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'Token is valid'
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 422 do
        key :description, 'Token is not valid'
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def check_reset
    @resource = User.find_by_reset_password_token(params[:reset_password_token])
    if @resource && @resource.reset_password_period_valid?
      json_response_success("Valid reset password token", true )
    else
      json_response_success("Invalid reset password token", false, :unprocessable_entity)
    end

  end
end