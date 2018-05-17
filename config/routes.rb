Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api', controllers: {sessions: 'application_sessions',
                                                               passwords: 'application_password'}
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
    get 'check_reset_token/:reset_password_token', to: 'reset_token#check_reset'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :apidocs, only: [:index]
end
