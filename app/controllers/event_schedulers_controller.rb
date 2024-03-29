class EventSchedulersController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:create, :index, :show, :calendar]
  before_action :set_schedule_resource, only: [:update]
  around_action :transactions_filter, only: [:create]

  swagger_path '/events/:event_id/schedules' do
    operation :get do
      key :summary, 'Events schedules list'
      key :description, 'Events Catalog'
      key :operationId, 'eventsSchedulesList'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :title
        key :in, :query
        key :description, 'Event filter'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Event Schedule response'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :EventSchedule
            end
            key :description, "Information container"
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
    title = params[:title]
    exclude = params[:exclude]
    schedules = @event.schedules.title_like(title)
    if exclude.present? and exclude.to_s == '1'
      player = Player.where(:event_id => @event.id).where(:user_id => @resource.id).first
      if player.present?
        ids = player.schedules.pluck(:id)
        schedules = schedules.where.not(:id => ids)
      end
    end
    json_response_serializer_collection(schedules, EventScheduleSerializer)
  end

  swagger_path '/events/:event_id/schedules' do
    operation :post do
      key :summary, 'Events schedules'
      key :description, 'Events Catalog'
      key :operationId, 'eventsSchedulesCreate'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :schedules
        key :in, :body
        key :description, 'Schedules array'
        key :required, true
        key :required, true
        schema do
          key :type, :array
          items do
            key :'$ref', :EventScheduleInput
          end
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :Event
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
    authorize Event
    if schedules_params.present?
      @event.sync_schedules! schedules_params
    else
      @event.schedules.create! schedule_param
    end
    json_response_serializer(@event, EventSerializer)
  end


  swagger_path '/events/:event_id/schedules/:id' do
    operation :get do
      key :summary, 'Events schedules show'
      key :description, 'Events Catalog'
      key :operationId, 'eventsSchedulesShow'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :description, 'Event Schedule response'
        schema do
          key :type, :object
          key :'$ref', :EventSchedule
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

  def show
    json_response_serializer(@event.schedules.where(:id => params[:id]).first!, EventScheduleSerializer)
  end

  def calendar
    response = []
    start_date = calendar_params[:start_date].to_date
    end_date = calendar_params[:end_date].to_date
    start_date.upto(end_date) do |date|
      my_calendar = EventCalendar.new
      brackest = EventContestCategoryBracketDetail.where(:start_date => date)
                     .where(:event_id => @event.id).order(start_date: :desc, time_start: :desc)
      unless calendar_params[:contest_id].nil?
        brackest = brackest.where(:contest_id => calendar_params[:contest_id])
      end
      my_calendar.brackets = brackest

      my_calendar.schedules = EventSchedule.where(:event_id => @event.id).date_in(date, date)
                                  .where.not(:agenda_type_id => AgendaType.competition_id).order(start_date: :desc, start_time: :desc)

      matches = Match.joins(round: [tournament: :contest]).merge(Tournament.where(:event_id => @event.id)).order(date: :desc)
                    .where(:date => date)
                    .select('matches.*', 'tournaments.event_bracket_id AS event_bracket_id', 'event_contests.index AS contest_index', "(SELECT agt.name FROM agenda_types AS agt WHERE agt.id = #{AgendaType.competition_id}) AS title",
                            'tournaments.category_id AS category_id')
      unless calendar_params[:contest_id].nil?
        matches = matches.merge(Tournament.where(:contest_id => calendar_params[:contest_id]))
      end
      my_calendar.matches = matches
      #json_response_serializer_collection(schedules, EventScheduleSerializer)
      #json_response_serializer_collection(brackest, EventContestCategoryBracketDetailSerializer)
      for_date = {}
      my_calendar.brackets.each do |item|
        if for_date[date.to_s].nil?
          for_date[date.to_s] = {}
          for_date[date.to_s]["brackets"] = []
        end
        for_date[date.to_s]["brackets"] << item
      end

      my_calendar.schedules.each do |item|
        if for_date[date.to_s].nil?
          for_date[date.to_s] = {}
          for_date[date.to_s]["schedules"] = []
        end
        if for_date[date.to_s]["schedules"].nil?
          for_date[date.to_s]["schedules"] = []
        end
        for_date[date.to_s]["schedules"] << item
      end

      my_calendar.matches.each do |item|
        if for_date[date.to_s].nil?
          for_date[date.to_s] = {}
          for_date[date.to_s]["matches"] = []
        end
        if for_date[date.to_s]["matches"].nil?
          for_date[date.to_s]["matches"] = []
        end
        for_date[date.to_s]["matches"] << item
      end
      for_date.each.with_index do |item, index|
        my_calendar_date = EventCalendarDate.new
        my_calendar_date.date = item[0]
        my_calendar_date.schedules = for_date[item[0]]["schedules"]
        my_calendar_date.brackets = for_date[item[0]]["brackets"]
        my_calendar_date.matches = for_date[item[0]]["matches"]
        response << my_calendar_date
      end
    end
    response = response.sort_by &:date
    json_response_serializer_collection(response, EventCalendarGroupedSerializer)
  end

  def update
    authorize Event
    @schedule.update!(schedule_param)
    #@event.remove_public_url
    json_response_serializer(@event, EventSerializer)
  end

  private

  def schedules_params
    #validate presence and type
    unless params[:schedules].nil? and !params[:schedules].kind_of?(Array)
      params[:schedules].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :agenda_type_id, :venue, :title, :instructor, :description, :start_date, :end_date, :start_time,
                                                               :end_time, :cost, :capacity, :category_id, :currency, :time_zone)
      end
    end
  end

  def schedule_param
    params.permit(:id, :agenda_type_id, :venue, :title, :instructor, :description, :start_date, :end_date, :start_time,
                  :end_time, :cost, :capacity, :category_id, :currency, :time_zone)
  end

  # search current resource of id
  def set_resource
    #apply policy scope
    @event = Event.find(params[:event_id])
  end

  def set_schedule_resource
    #apply policy scope
    @event = Event.find(params[:event_id])
    @schedule = @event.schedules.where(:id => params[:id]).first!
  end

  def calendar_params
    params.require(:start_date)
    params.require(:end_date)
    params.permit(:start_date, :end_date, :contest_id)
  end
end
