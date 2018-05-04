Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api', controllers: { sessions: 'application_sessions' }
=begin
  scope :api, defaults: { format: :json } do
    devise_for :users,  controllers: { sessions: 'application_sessions' }
  end
=end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :apidocs, only: [:index]
end
