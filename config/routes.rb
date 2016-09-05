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
    resources :scheduled_activities
    resource :itinerary do
      post :email
    end
    resource :account, only: [:show] do
      resources :payments, only: [:show, :new, :create]
    end
    scope "/:activity_type", constraints: { activity_type: /#{Activity.types.map(&:to_param).join('|')}/ } do
      get "/" => "activities#index", as: :activity_type
      get "/:id" => "activities#show", as: :activity
    end
    get "/activities" => "activities#index", as: :activities
    get "/" => "festivals#show", as: :festival
  end

  resource :profile, only: %i[show update]

  resources :calendars, only: [:show]

  post "/payments/paypal/:id" => "payments#paypal", as: :paypal_callback
  post "/payments/:id" => "payments#show", as: :paypal_return
  get "/payments/:id" => "payments#show"

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
        resources :schedules, only: [:new, :create, :edit, :update, :destroy]
      end
      resources :venues do
        put "reorder/:position" => "venues#reorder", on: :member
      end

      get "payments/settings" => "payment_configurations#edit",
        as: :payment_settings
      match "payments/settings", to: "payment_configurations#update",
        via: [:put, :patch]

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

      resources :vouchers

      get "/" => "dashboards#show"
    end

    resources :participants, as: :users
    get "/" => "dashboards#show"
  end

  mount LetterOpenerWeb::Engine, at: "/admin/emails" if Rails.env.development?

  root to: "festivals#index"
end
