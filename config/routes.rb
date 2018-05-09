Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api', controllers: { sessions: 'application_sessions',
                                                                passwords: 'application_password' }
  scope :api, defaults: { format: :json } do
    resources :users,  only: [:index, :create, :show, :update, :destroy]
    resources :sports,  only: [:index]
    get 'check_reset_token/:reset_password_token', to: 'reset_token#check_reset'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :apidocs, only: [:index]
end
