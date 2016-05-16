Rails.application.routes.draw do
  scope "/:year", constraints: { year: /\d{4}/ } do
    get "/" => "festivals#show"
  end

  root to: "festivals#index"
end
