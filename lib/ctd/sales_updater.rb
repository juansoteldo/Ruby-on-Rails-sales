module CTD
  class SalesUpdater
    def self.update
      range = [3.month.ago.beginning_of_month..Time.now.end_of_day]
      SalesTotal.where(sold_on: range).delete_all
      params = {
          created_at_min: 3.month.ago.beginning_of_month,
          created_at_max: Time.now.end_of_day
      }

      Rails.logger.debug "Loading attributed streak orders"
      orders = Shopify::Order.attributed params

      Rails.logger.debug "Calculating sales totals for #{orders.count} orders"
      orders.each do |order|
        total = SalesTotal.where( sold_on: order.created_at.to_date,
                                  salesperson_id: order.sales_id.to_i).first_or_create
        total.order_total += order.total_price.to_f.round(2)
        total.order_count += 1
        total.save!
      end

      Rails.logger.debug "Loading boxes"
      begin
        boxes = StreakAPI::Box.all
        Rails.logger.debug "Calculating lead counts for #{boxes.count} boxes"

        boxes.each do |box|
          next unless range.include?(box.creationTimestamp)
          next unless box.assignedToKeys.any?
          encrypted_key = Salesperson.encrypt_streak_api_key(box.assignedToKeys.first)
          salesperson = Salesperson.find_by_encrypted_streak_api_key encrypted_key
          next unless salesperson

          date = Time.new(box.creationTimestamp).to_date

          total = SalesTotal.where( sold_on: date,
                                    salesperson_id: salesperson.id).first_or_create
          total.box_count += 1
          total.save!
        end
      rescue
        Rails.logger.debug "Could not get a list of all the boxes"
      end
    end
  end
end
