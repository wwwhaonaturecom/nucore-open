NuCardconnect::Engine.routes.draw do
  get "/statements/:uuid/pay", to: "nu_cardconnect/payments#pay", as: "pay_statement"
  post "/statements/:uuid/process", to: "nu_cardconnect/payments#process_payment", as: "process_statement"

  get "/facilities/:id/merchant_account", to: "nu_cardconnect/merchant_accounts#edit", as: "edit_facility_merchant_account"
  put "/facilities/:id/merchant_account", to: "nu_cardconnect/merchant_accounts#update", as: "facility_merchant_account"
end
