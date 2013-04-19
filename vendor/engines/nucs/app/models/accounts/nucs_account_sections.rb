module Accounts::NucsAccountSections
  def account_number_fields
    #TODO Replace with normal hash in Ruby 1.9
    ActiveSupport::OrderedHash[:account_number, { :required => true },
      :program, {},
      :chart_field1, {}
    ]
  end

  def account_number_to_storage_format
    number = "#{account_number_parts.account_number}"
    if account_number_parts.program.present? || account_number_parts.chart_field1.present?
      number << "-#{account_number_parts.program}-#{account_number_parts.chart_field1}"
    end
    number
  end

  def account_number_to_s
    build_parts unless account_number_parts
    number = "#{account_number_parts.account_number}"
    if account_number_parts.program.present? || account_number_parts.chart_field1.present?
      number << " (#{account_number_parts.program}) (#{account_number_parts.chart_field1})"
    end
    number
  end

private

  def build_parts
    parts = self.account_number.split('-')
    self.account_number_parts = {
      :account_number => parts[0..3].join('-'),
      :program => parts[4],
      :chart_field1 => parts[5]
    }
  end
end
