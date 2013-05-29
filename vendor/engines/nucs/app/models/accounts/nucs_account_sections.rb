module Accounts::NucsAccountSections
  def account_number_fields
    #TODO Replace with normal hash in Ruby 1.9
    ActiveSupport::OrderedHash[
      :fund, { :length => 3 },
      :dept, { :length => 7 },
      :project, { :length => 8 },
      :activity, { :length => 2 },
      :program, { :length => 4 },
      :chart_field1, { :length => 4 }
    ]
  end

  def account_number_to_storage_format
    number = account_number_beginning
    if account_number_parts.program.present? || account_number_parts.chart_field1.present?
      number << "-#{account_number_parts.program}-#{account_number_parts.chart_field1}"
    end
    number
  end

  def account_number_to_s
    build_parts unless account_number_parts
    number = account_number_beginning
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

  def account_number_beginning
    a = account_number_parts # for brevity in string building
    number = [a.fund, a.dept, a.project, a.activity].reject(&:blank?).join('-')
  end

  def build_parts
    if self.account_number
      parts = self.account_number.split('-')
      self.account_number_parts = {
        :fund => parts[0],
        :dept => parts[1],
        :project => parts[2],
        :activity => parts[3],
        :program => parts[4],
        :chart_field1 => parts[5]
      }
    else
      self.account_number_parts = {}
    end
  end
end
