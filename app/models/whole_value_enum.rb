module WholeValueEnum

  extend ActiveSupport::Concern

  class_methods do
    def whole_value_enum(attribute, class_name: attribute.to_s.classify)
      validates attribute, presence: true, inclusion: class_name.constantize.all

      define_method attribute do
        class_name.constantize[self[attribute]]
      end

      define_method "#{attribute}=" do |value|
        self[attribute] = class_name.constantize[value]
      end
    end
  end

  class Value

    attr_reader :raw_value

    def self.all
      valid_values.map { |value| new(value) }
    end

    def self.[](raw_value)
      if raw_value.is_a?(self)
        raw_value
      elsif valid_values.include?(raw_value)
        new(raw_value)
      else
        InvalidValue.new(raw_value)
      end
    end

    def initialize(raw_value)
      @raw_value = raw_value
      raise ArgumentError, "Invalid value: #{raw_value}" unless self.class.valid_values.include?(raw_value)
      freeze
    end

    # to_label is a method by simple_form to generate the option name in dropdowns
    # that it tries before falling back to to_s
    def to_label
      I18n.t(raw_value, scope: self.class.name.underscore)
    end

    def to_s
      raw_value
    end

    def ==(other)
      case other
      when self.class
        raw_value == other.raw_value
      when String
        raw_value == other
      else
        false
      end
    end

  end

  class InvalidValue

    def initialize(raw_value)
      @raw_value = raw_value
    end

    def to_label
      "Invalid User Note Mode: #{@raw_value}"
    end

    def to_s
      to_label
    end

  end

end
