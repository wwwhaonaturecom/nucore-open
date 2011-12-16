module UserExtension

  # bcsec wants this for logging
  alias_attribute :personnel_id, :id


  def self.extended(base)
    base.class.after_create :find_or_create_person
    base.class.after_save :ensure_login_record_exists
    base.class.after_update :update_person
  end


  def price_groups
    groups = price_group_members.collect{ |pgm| pgm.price_group }
    # check internal/external membership
    groups << (self.username.match(/@/) ? PriceGroup.external.first : PriceGroup.base.first)
    # check cancer center membership
    begin
      result = Pers::Person.find_by_sql(["SELECT * from v_cancer_center_members where username = ?", self.username])
      groups << PriceGroup.cancer_center.first if result.length > 0
    rescue
    end
    groups.flatten.uniq
  end


  def password=(pwd)
    @_bcsec_password=pwd
  end


  def find_or_create_person
    raise 'could not create pers record' if Pers::Person.find_or_create_by_username({
      :first_name => first_name,
      :last_name => last_name,
      :email => email,
      :username => username,
      :entered_date => Time.zone.now,
      :plain_text_password => @_bcsec_password
    }).new_record?
  end


  def update_person
    pers=Pers::Person.find_by_username(username)
    raise 'could not find pers record' unless pers

    pers.update_attributes({
      :first_name => first_name,
      :last_name => last_name,
      :email => email,
      :changed_date => Time.zone.now,
      :plain_text_password => @_bcsec_password
    })

    pers.save!
  end


  def ensure_login_record_exists
    login = Pers::Login.first(:conditions => { :portal => 'nucore', :username => username })
    Pers::Login.create!(:portal_name => 'nucore', :username => username) unless login
  end

end