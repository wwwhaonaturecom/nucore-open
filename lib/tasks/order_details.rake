namespace :order_details  do
  desc "mark order_details with past reservations as complete"
  task :expire_reservations => :environment do
    AutoExpireReservation.new.perform
    EndReservationOnly.new.perform
  end

  desc "automatically switch off auto_logout instrument"
  task :auto_logout => :environment do
    AutoLogout.new.perform
  end

  desc "remove list of BIF order details"
  task clean_bif_orders: :environment do
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
  task remove_merge_orders: :environment do
    stale_merge_orders = Order.where("merge_with_order_id IS NOT NULL AND created_at <= ?", Time.zone.now - 4.weeks).all
    stale_merge_orders.each{|order| order.destroy }
  end


  desc "Retouch all complete order details and recalculate pricing"
  task recalculate_prices: :environment do
    # Change this query for when we need to recalculate prices for just a subset of Order details
    # Changes to this should be marked with the ticket number in the git commit message
    query = OrderDetail.where('fulfilled_at >= ? and fulfilled_at < ?',
      Time.zone.local(2014, 9, 1), Time.zone.local(2015, 1, 7).end_of_day)

    only_completed = query.where(state: 'complete', journal_id: nil, statement_id: nil)
      .joins(:order).where(orders: { state: 'purchased' })

    only_completed.readonly(false).each do |od|
      old_cost = od.actual_cost
      old_subsidy = od.actual_subsidy
      old_total = od.actual_total
      old_price_group = od.price_policy.try(:price_group)
      od.assign_price_policy(od.fulfilled_at || Time.zone.now)


      if od.price_group && (od.price_group != old_price_group)
        # Manually uncomment this line on the server before running to save changes
        # od.save!
        puts "#{od.facility.name}|#{od}|#{od.order_status}|#{od.account}|#{od.user}|#{od.product}|#{od.fulfilled_at}|#{old_price_group}|#{old_cost}|#{old_subsidy}|#{old_total}|#{od.price_policy.try(:price_group)}|#{od.actual_cost}|#{od.actual_subsidy}|#{od.actual_total}"
      end
    end
  end

  desc "Uncancels a list of order details. The file should contain just the OD ID, one per line"
  task :uncancel, [:filename] => :environment do |t, args|
    uncanceler = OrderUncanceler.new
    File.open(args[:filename]).each_line do |line|
      order_detail = OrderDetail.find_by_id(line.chomp)
      if order_detail
        uncanceler.uncancel_to_complete(order_detail)
      else
        puts "Could not find order detail #{line}"
      end
    end
  end
end
