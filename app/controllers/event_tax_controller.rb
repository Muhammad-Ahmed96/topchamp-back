class EventTaxController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:index]
  swagger_path '/events/:id/taxes' do
    operation :get do
      key :summary, 'Events taxes '
      key :description, 'Show tax'
      key :operationId, 'eventsTaxIndex'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :name, :categories
        key :description, 'categories'
        schema do
          key :type, :array
          items do
            key :'$ref', :CategoryBrackets
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
    tax = 0
    if @event.tax.present?
      if event.tax.is_percent
        tax = (@event.tax.tax * amount) / 100
      else
        tax = event.tax.tax
      end
    end
    json_response_data([:tax => tax])
  end

  private
  # search current resource of id
  def set_resource
    #apply policy scope
    @event = Event.find(params[:event_id])
  end
end
