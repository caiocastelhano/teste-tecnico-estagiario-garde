Rails.application.routes.draw do
  resources :appointments, only: [:index, :create]
  get "available", to: "appointments#available"
end