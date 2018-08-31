Rails.application.routes.draw do
  get 'tournament_matches_status/index'
  get 'event_schedulers/create'
  get 'event_registration_rules/create'
  get 'players/Index'
  mount_devise_token_auth_for 'User', at: 'api', controllers: {sessions: 'application_sessions',
                                                               passwords: 'application_password',
                                                               registrations: 'application_registrations'}
  scope :api, defaults: {format: :json} do
    resources :users, only: [:index, :create, :show, :update, :destroy] do
      collection do
        get :current_enrolls
      end
      member do
        put :activate
        put :inactive
        put :profile
        put :sing_up_information
      end
    end
    resources :sports, only: [:index]
    resources :event_types, only: [:index]
    resources :attendee_type, only: [:index]
    resources :roles, only: [:index]
    resources :geography, only: [:index]
    resources :status, only: [:index]
    resources :facilities, only: [:index]
    resources :days, only: [:index]
    resources :restrictions, only: [:index]
    resources :venue_facility_management, only: [:index]
    resources :venues, only: [:index, :create, :show, :update, :destroy] do
      member do
        put :activate
        put :inactive
      end
    end
    resources :sponsors, only: [:index, :create, :show, :update, :destroy] do
      member do
        put :activate
        put :inactive
      end
    end
    resources :agenda_types, only: [:index]
    resources :regions, only: [:index]
    resources :invitation_status, only: [:index]
    resources :languages, only: [:index]
    get 'check_reset_token/:reset_password_token', to: 'reset_token#check_reset'
    resources :application_confirmations, only: [:create]
    post 'application_confirmations/resend_pin', to: 'application_confirmations#resend_pin'

    resources :events, only: [:index, :create, :show, :update, :destroy] do
      collection do
        get :coming_soon
        get :upcoming
        scope :downloads do
          get :download_discounts_template, :path => :discounts_template
        end

      end
      member do
        put :create_venue
        put :venue
        put :activate
        put :inactive
        put :payment_information
        put :payment_method
        put :discounts
        put :import_discount_personalizeds
        put :tax
        put :refund_policy
        put :service_fee
        put :details
        put :agendas
        get :categories
        get :available_categories
        get :get_registration_fee, :path => :registration_fee
      end
      #Deleted  :create path
      resources :event_enrolls,only: [:index], :path => :enrolls do
        collection do
          post :user_cancel
          post :unsubscribe
          post :change_attendees
        end
      end
      resources :event_registration_rules, only: [:create], :path => "" do
        collection do
          put :create, :path => :registration_rule
        end
      end

      resources :event_schedulers, only: [:create, :index, :show], :path => :schedules
      resources :event_discounts, only: [], :path => :discounts do
        collection do
          get :validate
        end
      end

      resources :tournaments, only: [:create]do
        collection do
          get :players_list, :path => :players
          get :teams_list, :path => :teams
          get :rounds_list, :path => :rounds
          get :details
        end
      end
      resources :scores, only: [:create, :index]
      resources :wait_list, only: [:create, :index]
    end
    get 'events_validate_url', to: 'events#validate_url'
    resources :visibility, only: [:index]
    resources :categories, only: [:index]
    resources :elimination_formats, only: [:index]
    resources :brackets, only: [:index]
    resources :scoring_options, only: [:index]
    resources :skill_levels, only: [:index]
    resources :sport_regulators, only: [:index]

    resources :invitations, only: [:index, :show, :update, :destroy] do
      collection do
        get :download_template
        get :template_sing_up
        get :index_partner,  :path => "partner"
        post :event
        post :date
        post :sing_up
        post :partner
      end
      member do
        post :resend_mail
        post :enroll
        post :refuse
      end
    end
    resources :participants, only: [:index, :show] do
      member do
        put :update_attendee_types
        put :activate
        put :inactive
      end
    end
    resources :players, only: [:index, :create, :update, :show, :destroy] do
      collection do
        post :partner_mixed
        post :partner_double
        post :signature
        get :get_schedules, :path => :schedules
        get :validate_partner
        get :rounds
        get :categories
        get :brackets
        post :partners, action: :add_partner, controller: :player_partner
        get :partners, action: :get_my_partners, controller: :player_partner
      end
      member do
        put :activate
        put :inactive
        #get :wait_list
        get :enrolled
      end
    end
    resources :business_categories, only: [:index]
    resources :partners, only: [:index]

    namespace :payments do
      resources :profile, only: [:create, :destroy, :show]
      resources :credit_cards, only: [:index, :create, :destroy]
      resources :check_out, only: [] do
        collection do
          post :event
          post :subscribe
        end
      end
    end

    resources :tournaments, only: [:index]
    resources :tournament_matches_status, only: [:index]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :apidocs, only: [:index]
end
