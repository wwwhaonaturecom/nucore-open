module NuCardconnect

  module Uuid

    extend ActiveSupport::Concern

    included do
      before_validation :set_uuid
    end

    def set_uuid
      self.uuid ||= SecureRandom.uuid
    end

  end

end
