class RemoveFacilityAffiliateId < ActiveRecord::Migration
  def self.up
    #remove_column(:facilities, :pers_affiliate_id)
    puts ">>>>>>> YOU SHOULD DROP THE facilities.pers_affiliate_id column AFTER MIGRATING NU USERS! <<<<<<<"
  end

  def self.down
    #add_column(:facilities, :pers_affiliate_id, :integer)
    puts ">>>>>>> IF YOU DROPPED THE facilities.pers_affiliate_id column AFTER MIGRATING NU USERS, PUT IT BACK! <<<<<<<"
  end
end
