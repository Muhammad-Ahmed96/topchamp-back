class TournamentsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_event, only: [:players_list]

  swagger_path '/events/:event_id/tournaments/players' do
    operation :get do
      key :summary, 'Get player list event tournament'
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsPlayerList'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Player Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Player
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
  def players_list
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    players = @event.players.joins(:brackets).merge(PlayerBracket.where(:event_bracket_id => players_list_params[:bracket_id])
    .where(:category_id => players_list_params[:category_id]))
    if paginate.to_s == "0"
      json_response_serializer_collection(players.all, PlayerSerializer)
    else
      paginate players, per_page: 50, root: :data
    end
  end
  private
  def set_event
    @event = Event.find(params[:event_id])
  end
  
  def players_list_params
    params.required(:category_id)
    params.required(:bracket_id)
    params.permit(:category_id, :bracket_id)
  end
end
