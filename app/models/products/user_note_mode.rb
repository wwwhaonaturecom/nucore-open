module Products

  class UserNoteMode < WholeValueEnum::Value

    def self.valid_values
      %w(hidden optional required).freeze
    end

    def required?
      raw_value == "required"
    end

    def visible?
      raw_value != "hidden"
    end

  end

end
