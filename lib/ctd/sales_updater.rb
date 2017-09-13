module CTD
  class SalesUpdater
    def self.update
      range = 3.month.ago.beginning_of_month..Time.now.end_of_day
      epoch_range = range.begin.to_i..range.end.to_i
      SalesTotal.where(sold_on: range).delete_all
      params = {
          created_at_min: range.begin,
          created_at_max: range.end
      }
      Rails.logger.debug "Loading attributed streak orders for last three months"
      orders = Shopify::Order.attributed params

      Rails.logger.debug "Calculating sales totals for #{orders.count} orders"
      orders.each do |order|
        request = Request.find(order.request_id.to_i) if order.request_id.is_a?(String)
        request ||= Request.joins(:user).where(users: { email: order.customer.email } ).last

        puts "Cannot find request for #{order.customer.email}" unless request
        created_at = request ? request.created_at.to_date : order.created_at.to_date
        total = SalesTotal.where( sold_on: created_at,
                                  salesperson_id: order.sales_id.to_i).first_or_create
        total.order_total += order.total_price.to_f.round(2)
        total.order_count += 1
        total.save!
      end

      Rails.logger.debug "Updating box counts from last 3 months"
      done = false
      page = 1
      total_boxes = 0
      initial_count = Request.where.not(contacted_by_id: nil).count

      while !done do
        boxes = StreakAPI::Box.all_with_limits({ limit: "1000", page: page.to_s, sortBy: "creationTimestamp" })

        boxes.each do |box|
          epoch = box.creation_timestamp/1000
          (done = true) && break unless epoch_range === epoch
          created_at = Time.at(epoch)

          total_boxes += 1
          next unless box.assigned_to_sharing_entries
          assignees = box.assigned_to_sharing_entries.reject{|e| e.email == "sales@customtattoodesign.ca"}
          next unless assignees.count == 1
          salesperson = Salesperson.find_by_email assignees.first.email
          next unless salesperson
          customer_email = box.name.strip.downcase

          salesperson.claim_requests_with_email(customer_email, created_at - 1.day)

          sales_total = SalesTotal.where( sold_on: created_at.to_date,
                                    salesperson_id: salesperson.id).first_or_create
          sales_total.update_attribute :box_count, sales_total.box_count + 1

        end
        puts "Processed #{page * 1000} boxes, last was on #{Time.at(boxes.last.creation_timestamp/1000).to_date}"
        page += 1

      end
      final_count = Request.where.not(contacted_by_id: nil).count
      puts "Updated salespeople for #{final_count - initial_count} requests based on #{total_boxes} boxes"

    end
  end
end
