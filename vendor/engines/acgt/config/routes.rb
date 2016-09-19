Rails.application.routes.draw do
  namespace :api do
    namespace :acgt do
      resources :order_details, only: [:index, :show]
    end
  end
end
