Rails.application.routes.draw do
  get 'registrations/new'

  scope "/:year", constraints: { year: /\d{4}/ } do
    resource :registration, only: %i[show update]
    resource :register, as: :registration, controller: "registrations",
      only: %i[new create]
    get "/" => "festivals#show", as: :festival
  end

  root to: "festivals#index"
end
