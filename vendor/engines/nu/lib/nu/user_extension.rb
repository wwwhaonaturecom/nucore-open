module Nu
  module UserExtension
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
  end
end