class DevicesController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:create]
  swagger_path '/devices' do
    operation :post do
      key :summary, 'Save a devices'
      key :description, 'Devices'
      key :operationId, 'devicesSave'
      key :produces, ['application/json',]
      key :tags, ['devices']
      parameter do
        key :name, :token
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
    device = Device.where(:token => create_params[:token])
                          .update_or_create!({:token => create_params[:token], :platform => create_params[:platform],
                                             :user_id => @resource.id})
    json_response_success(t("created_success", model: Device.model_name.human), true)
  end

  swagger_path '/devices/:token' do
    operation :delete do
      key :summary, 'Delete a devices'
      key :description, 'Devices'
      key :operationId, 'devicesDelete'
      key :produces, ['application/json',]
      key :tags, ['devices']
      parameter do
        key :name, :token
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
  def destroy
    device = Device.where(:token => params[:id]).first!
    device.destroy
    json_response_success(t("deleted_success", model: Device.model_name.human), true)
  end
  private
  def create_params
    params.require(:token)
    params.permit(:token, :platform)
  end
end
