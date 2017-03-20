module NuResearchSafety

  class Certificate < ActiveRecord::Base

    include ActiveModel::ForbiddenAttributesProtection

    self.table_name = "nu_safety_certificates"

    belongs_to :deleted_by, class_name: 'User'

    acts_as_paranoid # soft-delete functionality

    validates :name, presence: true
    validates :name, uniqueness: { scope: :deleted_at }

    scope :ordered, -> { order(:name) }
  end

end
