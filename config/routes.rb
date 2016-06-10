Rails.application.routes.draw do
  devise_scope :user do
    get "/login" => "devise/sessions#new", as: :login
    delete "/logout" => "devise/sessions#destroy", as: :logout
    get "/signup" => "signup#new", as: :user_signup
    post "/signup" => "signup#create"
  end

  devise_for :users, controllers: { registrations: 'signup' }

  scope "/:year", constraints: { year: /\d{4}/ } do
    post "/register/login" => "registrations#login", as: :register_and_login
    get "/register/:step" => "registrations#new", as: :registration_step
    get "/register" => "registrations#new"
    post "/register" => "registrations#create"
    resource :registration, only: %i[show update]
    get "/" => "festivals#show", as: :festival
  end

  namespace :admin do
    scope "/:year", constraints: { year: /\d{4}/ } do
      resource :festival, only: [:show, :edit, :update]
      resources :participants, only: [:index, :show], as: :festival_participants do
        resource :registration
      end
      resources :registrations
    end

    resources :participants
  end

  root to: "festivals#index"
end
