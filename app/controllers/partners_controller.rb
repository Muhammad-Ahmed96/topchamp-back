class PartnersController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/partners' do
    operation :get do
      key :summary, 'Get partners'
      key :description, 'Partners Catalog'
      key :operationId, 'partnersIndex'
      key :produces, ['application/json',]
      key :tags, ['partners']
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
        key :description, 'Direction to order, (ASC or DESC)'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :search
        key :in, :query
        key :description, 'Keyword to search'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :event_id
        key :in, :query
        key :description, 'Event to add'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end

      parameter do
        key :name, :type
        key :in, :query
        key :description, 'Type {nil or doubles or mixed}'
        key :required, false
        key :type, :integer
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
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'first_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    event_id = params[:event_id]
    event  = Event.where(id: event_id).first
    if event.nil?
      return json_response_error([t("not_event")], 422)
    end
    type = params[:type]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    player = Player.where(user_id: @resource.id).where(event_id: event_id).first_or_create!
    not_in = nil;
    if type == "doubles"
      not_in = player.partner_double_id
    elsif type == "mixed"
      not_in = player.partner_mixed_id
    end

    users =  User.my_order(column, direction).search(search).where.not(id: [not_in, @resource.id])
    if paginate.to_s == "0"
      json_response_serializer_collection(users.all, UserSingleSerializer)
    else
      paginate users, per_page: 50, root: :data
    end
  end
end
