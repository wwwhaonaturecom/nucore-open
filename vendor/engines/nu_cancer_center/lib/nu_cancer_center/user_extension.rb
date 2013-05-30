module NuCancerCenter
  module UserExtension
    def price_groups
      groups = price_group_members.collect{ |pgm| pgm.price_group }
      # check internal/external membership
      groups << (self.username.match(/@/) ? PriceGroup.external.first : PriceGroup.base.first)

      groups << PriceGroup.cancer_center.first if CancerCenterMember.exists?(:username => self.username)

      groups.flatten.uniq
    end
  end
end
