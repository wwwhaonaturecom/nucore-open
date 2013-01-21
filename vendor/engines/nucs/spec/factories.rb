#
# Do not load application overriding factories if we
# are running the engine stand alone
unless Rails.root.to_s.include?('/vendor/engines/nucs')
  FactoryGirl.define do
    factory :nufs_account do
      sequence(:account_number) do |n|
        # 9XX-7777777
        account = "9#{'%02d' % (n%100)}-7777777" # fund3-dept7
        # Defined here as opposed to in an after_build hook
        # since some tests rely on it being defined on attributes_for
        define_gl066 account
        account
      end
      description 'nufs account description'
      expires_at { Time.zone.now + 1.month }
      created_by 0
      
    end
  end
end

FactoryGirl.define do
  factory :nucs_grants_budget_tree do
    account '77599'
    account_desc 'Other Capital Equipment'
    roll_up_node '77501'
    roll_up_node_desc 'Capital Equipment, Restricted'
    parent_node "70000"
    parent_node_desc "Non-Personnel Expenses"
    account_effective_at "2008-12-01"
    tree "NU_GM_BUDGET"
    tree_effective_at "1970-01-01"
  end


  factory :nucs_gl066_with_dates, :class => NucsGl066 do
    budget_period '-'
    fund '610'
    department '4735000'
    project '60028213'
    activity '01'
    account '78700'
    starts_at '2010-09-01'
    expires_at '2011-08-31'
  end


  factory :nucs_gl066_without_dates, :parent => :nucs_gl066_with_dates do
    budget_period '2010'
    starts_at nil
    expires_at nil
  end


  factory :nucs_fund do
    value '171'
    auxiliary 'Designated|DESIGNATED'
  end


  factory :nucs_account do
    value '75340'
    auxiliary 'Laboratory Services|LAB SERVIC'
  end


  factory :nucs_department do
    value '5308000'
    auxiliary 'A|Gastroenterology|GASTRO||'
  end


  factory :nucs_program do
    value '1059'
    auxiliary 'CV Research Fellowship|CV FW'
  end


  factory :nucs_chart_field1 do
    value '1093'
    auxiliary 'Fastbreak Friday|FASTBREAK'
  end


  factory :nucs_project_activity do
    project '10006346'
    activity '01'
    auxiliary 'Dr. Khazaie Pi Account|01-JAN-01|31-AUG-49|'
  end
end