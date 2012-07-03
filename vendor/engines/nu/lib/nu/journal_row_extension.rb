module Nu
  module JournalRowExtension

    def self.included(base)
      base.validates_presence_of :fund, :dept
    end

  end
end