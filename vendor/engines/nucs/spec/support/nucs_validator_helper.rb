module NucsValidatorHelper
  #
  # Seeds the DB with a GL066 record for validation of +chart_string+
  # [_chart_string_]
  #   A +ValidatorFactory#pattern+ matching +String+
  # [_attrs_]
  #   Overrides for the +NucsGl066+ Factory, if any
  def define_gl066(chart_string, attrs={})
    validator = NucsValidator.new(chart_string)
    raise Exception.new("#{chart_string} does not match #{NucsValidator.pattern}") unless validator.valid?
    attrs.merge!(:fund => validator.fund) unless attrs.has_key?(:fund)
    attrs.merge!(:department => validator.department) unless attrs.has_key?(:department)
    attrs.merge!(:project => validator.project) if validator.project and not attrs.has_key?(:project)
    attrs.merge!(:activity => validator.activity) if validator.activity and not attrs.has_key?(:activity)

    if attrs.has_key?(:expires_at) or attrs.has_key?(:starts_at)
      FactoryGirl.create(:nucs_gl066_with_dates, attrs)
    else
      unless attrs.has_key?(:budget_period)
        today=Time.zone.today
        period=(today+1.year).year
        period=today.year if Time.zone.parse("#{period}0901")-1.year > today
        attrs.merge!(:budget_period => period)
      end

      gl=FactoryGirl.create(:nucs_gl066_without_dates, attrs)
    end

    FactoryGirl.create(:nucs_chart_field1, :value => validator.chart_field1) if validator.chart_field1
  end


  #
  # Seeds the DB with GE001 records for validation of +chart_string+
  # [_chart_string_]
  #   A +ValidatorFactory#pattern+ matching +String+
  def define_ge001(chart_string)
    validator = NucsValidator.new(chart_string)
    FactoryGirl.create(:nucs_fund, :value => validator.fund)
    FactoryGirl.create(:nucs_department, :value => validator.department)

    if validator.project
      project_activity={ :project => validator.project }
      project_activity.merge!(:activity => validator.activity) if validator.activity
      FactoryGirl.create(:nucs_project_activity, project_activity)
    end

    FactoryGirl.create(:nucs_program, :value => validator.program) if validator.program
    FactoryGirl.create(:nucs_chart_field1, :value => validator.chart_field1) if validator.chart_field1
  end


  #
  # Seeds the DB so that +account+ is open for +chart_string+
  # [_account_]
  #   A chart string account component
  # [_chart_string_]
  #   A +ValidatorFactory#pattern+ matching +String+
  # [_budget_tree_attrs_]
  #   Overrides for the +NucsGrantsBudgetTree+ Factory, if any
  # [_gl066_attrs_]
  #   Overrides for the +NucsGl066+ Factory, if any
  def define_open_account(account, chart_string, budget_tree_attrs={}, gl066_attrs={})
    tree=FactoryGirl.create(:nucs_grants_budget_tree, budget_tree_attrs.merge(:account => account))
    define_ge001(chart_string)
    define_gl066(chart_string, gl066_attrs.merge(:account => tree.roll_up_node))
  end

end
