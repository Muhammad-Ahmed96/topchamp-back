class EventDiscountsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:validate]

  swagger_path '/events/:event_id/discounts/validate' do
    operation :get do
      key :summary, 'Events discounts validate'
      key :description, 'Events Catalog'
      key :operationId, 'eventsDiscountsValidate'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :description, 'Event discounts response'
        schema do
          key :type, :object
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
  def validate
    discount = @event.discount_generals.where(:code => discount_params[:code]).first
    personalized = @event.discount_personalizeds.where(:email => @resource.email, :code => discount_params[:code] ).first
    if personalized.nil? and discount.nil?
      return json_response_error([t("events.discounts.invalid")], 401)
    elsif discount.present? and  discount.limited <= discount.applied
      return json_response_error([t("events.discounts.limit_reached")], 401)
    end
    return json_response_success(t("events.discounts.valid"), true)
  end

  private


  def discount_params
    params.permit(:code)
  end

  # search current resource of id
  def set_resource
    #apply policy scope
    @event = Event.find(params[:event_id])
  end
end
