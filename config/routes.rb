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
    resource :itinerary do
      post :email
    end
    resource :account, only: [:show] do
      resources :payments, only: [:show, :new, :create]
    end
    get "/" => "festivals#show", as: :festival
  end

  resources :calendars, only: [:show]

  post "/payments/paypal/:id" => "payments#paypal", as: :paypal_callback
  post "/payments/:id" => "payments#show", as: :paypal_return

  namespace :admin do
    scope "/:year", constraints: { year: /\d{4}/ } do
      resource :festival, only: [:show, :edit, :update]
      resources :participants do
        resource :registration
      end
      resources :packages do
        put "reorder/:position" => "packages#reorder", on: :member
      end
      resources :activities
      resources :facilitators
      resource :timetable do
        resources :schedules, only: [:create, :edit, :update, :destroy]
      end
      resources :venues do
        put "reorder/:position" => "venues#reorder", on: :member
      end
      resources :payments do
        collection do
          get "/:filter" => "payments#index", as: :filtered,
            constraints: { filter: /#{Payment.statuses.keys.join("|")}/ }
        end
        member do
          put :approve
          put :decline
        end
      end

      get "/" => "dashboards#show"
    end

    resources :participants, as: :users
    get "/" => "dashboards#show"
  end

  mount LetterOpenerWeb::Engine, at: "/admin/emails" if Rails.env.development?

  root to: "festivals#index"
end
