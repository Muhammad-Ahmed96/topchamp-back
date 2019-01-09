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
        get :taken_brackets
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

      resources :event_schedulers, only: [:create, :index, :show, :update], :path => :schedules do
        collection do
          get :calendar
        end
      end
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
          put :update_matches
        end
      end
      resources :scores, only: [:create, :index] do
        collection do
          get :match_details
        end
      end
      resources :wait_list, only: [:create, :index]
      resources :event_brackets, only: [] do
        collection do
          get :available
        end
      end

      resources :event_tax, only: [:index], :path => :taxes
      #Event contest
      resources :event_contest, only: [:destroy, :index], :path => :contest do
        member do
          delete 'change_type',  action: :change_type
        end
        resources :event_contest_categories, only: [:destroy, :index], :path => :category do
          resources :event_contest_category_brackets, only: [:destroy], :path => :brackets do
            collection do
              get 'available',  action: :available
              delete 'details/:id',  action: :destroy_detail
            end
          end
        end
      end

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
        get :rival_info
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
      resources :profiles, only: [:create, :destroy, :show]
      resources :credit_cards, only: [:index, :create, :destroy]
      resources :check_out, only: [] do
        collection do
          post :event
          post :subscribe
          post :schedule
        end
      end
      resources :refunds, only: [] do
        collection do
          post :credit_card
          post :bank_account
        end
      end
    end

    resources :tournaments, only: [:index]
    resources :tournament_matches_status, only: [:index]

    resources :event_fees, only: [:create, :index] do
      collection do
        get :calculate
        delete :delete_discount
      end
    end

    resources :certify_score, only: [:create, :show, :update]
    resources :devices, only: [:create, :destroy]
    resources :user_event_reminder, only: [:create],  :path => :event_reminder

    namespace :reports do
      get 'events/:event_id/participant_payment', action: :participant_payment, controller: :events
      get 'events/:event_id/registration_status', action: :registration_status, controller: :events
      get 'events/:event_id/agenda_registration', action: :agenda_registration, controller: :events

      get 'admin/:user_id/revenue', action: :revenue, controller: :admin
      get 'admin/:user_id/report', action: :report, controller: :admin
      get 'reports/:user_id/account', action: :account, controller: :reports
      get 'reports/transaction', action: :transaction, controller: :reports
      get 'director/balance', action: :balance, controller: :director
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :apidocs, only: [:index]
end
