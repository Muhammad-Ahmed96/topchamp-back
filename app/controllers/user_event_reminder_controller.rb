class UserEventReminderController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/event_reminder' do
    operation :post do
      key :summary, 'Set event reminder'
      key :description, 'User Catalog'
      key :operationId, 'eventReminderCreate'
      key :produces, ['application/json',]
      key :tags, ['event_reminder']
      parameter do
        key :name, :event_id
        key :in, :body
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :reminder
        key :in, :body
        key :required, true
        key :type, :integer
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
    UserEventReminder.where(:user_id => @resource.id).where(:event_id => create_params[:event_id])
        .update_or_create!({:reminder => create_params[:reminder], :user_id => @resource.id, :event_id => create_params[:event_id]})
    json_response_success(t("created_success", model: UserEventReminder.model_name.human), true)
  end

  private
  def create_params
    params.required(:event_id)
    params.required(:reminder)
    params.permit(:event_id, :reminder)
  end
end
