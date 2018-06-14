Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api', controllers: {sessions: 'application_sessions',
                                                               passwords: 'application_password',
                                                               registrations: 'application_registrations'}
  scope :api, defaults: {format: :json} do
    resources :users, only: [:index, :create, :show, :update, :destroy] do
      member do
        put :activate
        put :inactive
        put :profile
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
    resources :languages, only: [:index]
    get 'check_reset_token/:reset_password_token', to: 'reset_token#check_reset'
    resources :application_confirmations, only: [:create]
    post 'application_confirmations/resend_pin', to: 'application_confirmations#resend_pin'

    resources :events, only: [:index, :create, :show, :update, :destroy] do
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
        put :registration_rule
        put :details
        put :agendas
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
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :apidocs, only: [:index]
end
