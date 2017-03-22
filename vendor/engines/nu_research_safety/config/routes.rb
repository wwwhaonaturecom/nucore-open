Rails.application.routes.draw do
  resources :certificates, except: :show, controller: "nu_research_safety/certificates"

  resources :facilities, except: [], path: I18n.t("facilities_downcase") do
    resources :products, only: [] do
      resources :product_certification_requirements, only: [:index, :create, :destroy],
                                                     path: "certification_requirements",
                                                     controller: "nu_research_safety/product_certification_requirements"
    end
  end
end
