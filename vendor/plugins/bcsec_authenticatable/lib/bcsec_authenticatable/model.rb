module Devise
  module Models
    module BcsecAuthenticatable

      def self.included(base)
        base.class_eval { attr_accessor :password }
      end

    end
  end
end