module CTD
  class SalesUpdater
    def self.update
      SalesTotal.where(sold_on: [3.month.ago.beginning_of_month..Time.now.end_of_day]).delete_all
      params = {
          created_at_min: 3.month.ago.beginning_of_month,
          created_at_max: Time.now.end_of_day
      }
      orders = Shopify::Order.attributed params
      orders.each do |order|
        total = SalesTotal.where( sold_on: order.created_at.to_date,
                                  salesperson_id: order.sales_id.to_i).first_or_create
        total.order_total += order.total_price.to_f.round(2)
        total.order_count += 1
        total.save!
      end
    end
  end
end
