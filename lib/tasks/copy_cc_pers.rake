task copy_cc_pers: :environment do
  class CancerCenterMember < ActiveRecord::Base
    self.table_name = "v_cancer_center_members"
    establish_connection "cc_pers"
  end

  def user_to_s(user)
    "user '#{user.username}'" +
    (user.email.present? ? " (#{user.email})" : "")
  end

  cc_price_group = PriceGroup.cancer_center.first

  CancerCenterMember.all.each do |cc_user|
    user = User.find_by_username(cc_user.username) || User.find_by_email(cc_user.email)
    if user.blank?
      puts "Can't find user for cc_pers user #{cc_user.username} (#{cc_user.email})"
      next
    end

    if UserPriceGroupMember.where(user_id: user.id, price_group_id: cc_price_group.id).any?
      puts "#{user_to_s(cc_user)} is already a member of #{cc_price_group.name}"
      next
    end

    begin
      UserPriceGroupMember.create!(user_id: user.id, price_group_id: cc_price_group.id)
      puts "Added #{user_to_s(cc_user)} to #{cc_price_group.name}"
    rescue => e
      puts "Unable to add #{user_to_s(cc_user)} to #{cc_price_group.name}: #{e}"
    end
  end
end
