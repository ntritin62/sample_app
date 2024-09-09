Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "static_pages/help"
    get "static_pages/contact"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources  :users, only: %i(show)
  end
end
