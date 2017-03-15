Rails.application.routes.draw do
  resources :certificates, except: :show, controller: "nu_research_safety/certificates"
end
