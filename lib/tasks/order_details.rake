namespace :order_details  do
  desc "mark order_details with past reservations as complete"
  task :expire_reservations => :environment do
    complete    = OrderStatus.find_by_name!('Complete')
    order_details = OrderDetail.where("(state = 'new' OR state = 'inprocess') AND order_status_id IS NOT NULL AND reservations.reserve_end_at < ? AND canceled_at IS NULL", Time.zone.now - 12.hours).
                               joins(:reservation).readonly(false).all
    order_details.each do |od|
      od.transaction do
        begin
          od.change_status!(complete)
          od.fulfilled_at = od.reservation.reserve_end_at
          next unless od.price_policy
          costs = od.price_policy.calculate_cost_and_subsidy(od.reservation)
          next if costs.blank?
          od.actual_cost    = costs[:cost]
          od.actual_subsidy = costs[:subsidy]
          od.save!
        rescue Exception => e
          STDERR.puts "Error on Order # #{od} - #{e}\n#{e.backtrace.join("\n")}"
          raise ActiveRecord::Rollback
        end
      end
    end
  end
  
  desc "automatically switch off auto_logout instrument"
  task :auto_logout => :environment do
    complete    = OrderStatus.find_by_name!('Complete')
    order_details = OrderDetail.where("(state = 'new' OR state = 'inprocess') AND reservations.actual_end_at IS NULL AND canceled_at IS NULL AND reserve_end_at < ?", Time.zone.now - 1.hour).
                               joins(:reservation).
                               includes(:product).
                               readonly(false).all
    order_details.each do |od|
      next unless od.product.relay.try(:auto_logout) == true

      od.transaction do
        begin
          od.reservation.actual_end_at = Time.zone.now
          od.change_status!(complete)
          next unless od.price_policy
          costs = od.price_policy.calculate_cost_and_subsidy(od.reservation)
          next if costs.blank?
          od.actual_cost    = costs[:cost]
          od.actual_subsidy = costs[:subsidy]
          od.save!
        rescue Exception => e
          STDERR.puts "Error on Order # #{od} - #{e}"
          raise ActiveRecord::Rollback
        end
      end
    end
  end
  
  desc "remove list of BIF order details"
  task :clean_bif_orders => :environment do
    class OrderDetailCleaner
      def self.remove_order(order_detail)
        order = order_detail.order
        journal = order_detail.journal
        puts "need to check journal" if journal
        
        statement = order_detail.statement
        puts "need to check statement" if statement
        
        puts "destroying detail #{order_detail.id}"
        order_detail.destroy
        
        if order.order_details.empty?
          puts "destroying order #{order.id}"
          order.destroy
        end    
        
      end
      
      def self.remove_orders(file)
        OrderDetail.transaction do
          File.open(file, "r").each_line do |line|
            next unless /([0-9]+)-([0-9]+)/ =~ line
            
            remove_order(OrderDetail.find($2))        
          end
        end
        puts "Done"
      end
    end
    OrderDetailCleaner.remove_orders("lib/tasks/orders_to_remove.txt")
  end

  desc "task to remove merge orders that have been abandoned. See Task #48377"
  task :remove_merge_orders => :environment do
    stale_merge_orders=Order.where("merge_with_order_id IS NOT NULL AND created_at <= ?", Time.zone.now - 4.weeks).all
    stale_merge_orders.each{|order| order.destroy }
  end

  desc "Retouch all complete order details and recalculate pricing"
  task :recalculate_prices, [:facility_slug] => :environment do |t, args|
    Facility.find_by_url_name('path').order_details.where(:state => 'complete').each do |od|
      old_cost = od.actual_cost
      old_subsidy = od.actual_subsidy
      old_total = od.actual_total
      old_price_group = od.price_policy.try(:price_group)
      od.assign_price_policy(od.fulfilled_at)
      puts "#{od}|#{od.order_status}|#{od.account}|#{od.user}|#{od.product}|#{od.fulfilled_at}|#{old_price_group}|#{old_cost}|#{old_subsidy}|#{old_total}|#{od.price_policy.try(:price_group)}|#{od.actual_cost}|#{od.actual_subsidy}|#{od.actual_total}|#{od.actual_total == old_total}"
    end

  end
end
