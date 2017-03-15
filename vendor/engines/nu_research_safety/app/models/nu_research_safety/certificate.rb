module NuResearchSafety

  class Certificate < ActiveRecord::Base

    include ActiveModel::ForbiddenAttributesProtection

    self.table_name = "nu_safety_certificates"

    validates :name, presence: true, uniqueness: true

    scope :ordered, -> { order(:name) }

  end

end
