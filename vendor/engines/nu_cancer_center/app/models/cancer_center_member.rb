class CancerCenterMember < ActiveRecord::Base
  set_table_name 'v_cancer_center_members'
  establish_connection 'cc_pers'
end
