class CancerCenterMember < ActiveRecord::Base
  self.table_name = 'v_cancer_center_members'
  establish_connection 'cc_pers'
end
