module PowerRelay
  def self.included(base)
    base.validates_presence_of :ip, :port, :username, :password
  end
end
