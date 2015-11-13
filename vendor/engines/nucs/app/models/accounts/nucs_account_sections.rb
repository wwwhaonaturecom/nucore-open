module Accounts::NucsAccountSections

  def account_number_fields
    example_validator.components.inject({}) do |hash, (field, value)|
      hash[field] = { length: value.length }
      hash
    end
  end

  def account_number_to_storage_format
    number = account_number_beginning
    if account_number_parts.program.present? || account_number_parts.chart_field1.present?
      number << "-#{account_number_parts.program}-#{account_number_parts.chart_field1}"
    end
    trim(number)
  end

  def account_number_to_s
    build_parts unless account_number_parts
    number = trim(account_number_beginning)
    if account_number_parts.program.present? || account_number_parts.chart_field1.present?
      number << " (#{account_number_parts.program}) (#{account_number_parts.chart_field1})"
    end
    number
  end

  def account_number_parts
    build_parts unless @account_number_parts
    @account_number_parts
  end

  private

  def example_validator
    @example_validator ||= ValidatorFactory.instance(ValidatorFactory.pattern_format)
  end

  def account_number_beginning
    a = account_number_parts
    [a.fund, a.dept, a.project, a.activity].join("-")
  end

  def build_parts
    self.account_number_parts = ValidatorFactory.instance(account_number).components if account_number
  end

  def trim(str)
    str.sub(/-+\z/, "")
  end

end
