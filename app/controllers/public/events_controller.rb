class Public::EventsController < ApplicationController
  include Swagger::Blocks
  def index

    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    title = params[:title]
    start_date = params[:start_date]
    status = params[:status]
    visibility = params[:visibility]


    state = params[:state]
    city = params[:city]

    sport_id = params[:sport_id]
    column_sports = nil
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end


    column_venue = nil
    if column.to_s == "state" || column.to_s == "city"
      column_venue = column
      column = nil
    end
    events =  Event.my_order(column, direction).venue_order(column_venue, direction).sport_in(sport_id).sports_order(column_sports, direction).title_like(title)
                 .start_date_like(start_date).in_status(status).state_like(state).city_like(city).in_visibility(visibility)

    if paginate.to_s == "0"
      json_response_serializer_collection(events.all, EventSerializer)
    else
      paginate events, per_page: 50, root: :data
    end
  end

  def coming_soon

    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    title = params[:title]


    state = params[:state]
    city = params[:city]

    sport_id = params[:sport_id]
    column_sports = nil
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end


    column_venue = nil
    if column.to_s == "state" || column.to_s == "city"
      column_venue = column
      column = nil
    end
    events = Event.coming_soon.my_order(column, direction).venue_order(column_venue, direction).sport_in(sport_id).sports_order(column_sports, direction).title_like(title)
                 .in_status("Active").state_like(state).city_like(city).in_visibility("Public")
    if paginate.to_s == "0"
      json_response_serializer_collection(events.all, EventSerializer)
    else
      paginate events, per_page: 50, root: :data
    end
  end
  def upcoming
    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    title = params[:title]


    state = params[:state]
    city = params[:city]

    sport_id = params[:sport_id]
    column_sports = nil
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end


    column_venue = nil
    if column.to_s == "state" || column.to_s == "city"
      column_venue = column
      column = nil
    end
    director_id = nil
    events = Event.upcoming.my_order(column, direction).venue_order(column_venue, direction).sport_in(sport_id).sports_order(column_sports, direction).title_like(title)
                 .in_status("Active").state_like(state).city_like(city).in_visibility("Public").only_directors(director_id)
    if paginate.to_s == "0"
      json_response_serializer_collection(events.all, EventSerializer)
    else
      paginate events, per_page: 50, root: :data
    end
  end

  def show
    @event = Event.find(params[:id])
    json_response_serializer(@event, EventSerializer)
  end


  swagger_path '/public/events/by_url/:uri' do
    operation :get do
      key :summary, 'Show event by url param'
      key :description, 'Event Catalog'
      key :operationId, 'eventsShow'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :uri
        key :in, :path
        key :description, 'Uri of event to fetch'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'Event Respone'
        schema do
          property :data do
            key :'$ref', :Event
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

  def by_url
    # authorize Event
    uri = params[:uri].nil? ? 'not_found' : params[:uri]
    @event = Event.in_visibility('Public').in_status('Active').url_like(uri).first!
    json_response_serializer(@event, EventSerializer)
  end
end
