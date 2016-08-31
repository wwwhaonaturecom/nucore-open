module Acgt

  module Admin

    module SubmissionsControllerExtension

      extend ActiveSupport::Concern

      included do
        skip_before_action :assert_sanger_enabled_for_facility, only: :show
        layout "application"
      end

    end

  end

end
