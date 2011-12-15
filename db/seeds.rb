# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

OrderStatus.create(:name => 'New')
OrderStatus.create(:name => 'In Process')
OrderStatus.create(:name => 'Cancelled')
OrderStatus.create(:name => 'Complete')
OrderStatus.create(:name => 'Reconciled')


p = PriceGroup.new(:name => 'Base Rate', :is_internal => true, :display_order => 1)
p.save(:validate => false)
p = PriceGroup.new(:name => 'Cancer Center Rate', :is_internal => true, :display_order => 2)
p.save(:validate => false)
p = PriceGroup.new(:name => 'External Rate', :is_internal => false, :display_order => 3)
p.save(:validate => false)
