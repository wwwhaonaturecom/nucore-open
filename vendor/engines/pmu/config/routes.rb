Rails.application.routes.draw do
  match 'facilities/:facility_id/general_reports/department' => 'general_reports#department', :as => 'department_facility_general_reports', :via => [ :post, :get ]
  match '/facilities/:facility_id/instrument_reports/department' => 'instrument_reports#department', :as => 'department_facility_instrument_reports', :via => [ :get, :post ]
end
