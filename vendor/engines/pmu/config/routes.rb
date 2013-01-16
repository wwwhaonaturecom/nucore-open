Rails.application.routes.draw do
  match 'facilities/:facility_id/general_reports/department' => 'general_reports#department', :as => 'department_facility_general_reports', :via => [ :post, :get ]
end
