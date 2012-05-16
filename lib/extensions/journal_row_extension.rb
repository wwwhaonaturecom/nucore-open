module JournalRowExtension

  def self.extended(base)
    base.class.validates_presence_of :fund, :dept
  end

end