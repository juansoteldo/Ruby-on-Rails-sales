# frozen_string_literal: true

module CTD
  class SalesUpdater
    MONTHS = Rails.env.test? ? 1 : 3
    MONTHS_TEXT = ActionController::Base.helpers.pluralize(MONTHS, "month")

    class << self
      def update
        range = MONTHS.month.ago.beginning_of_month..Time.now.end_of_day

        SalesTotal.where(sold_on: range).delete_all
        update_sales_totals(range)
        update_conversion_rates(range)
        true
      rescue => e
        console_log e.message
        console_log e.backtrace.join("\n")
        false
      end

      def update_sales_totals(range)
        params = {
          created_at_min: range.begin,
          created_at_max: range.end,
        }

        console_log "Loading attributed shopify orders for last #{MONTHS_TEXT}"
        orders = MostlyShopify::Order.deposits params

        console_log "Calculating sales totals for #{orders.count} orders"
        orders.each do |order|
          request = order.request(reset_attribution: true)
          Rails.logger.warn("Cannot find request for #{order.customer.email}") unless request

          sales_id = order.sales_id
          quoted_by_id = order.request&.quoted_by_id

          if sales_id && request && quoted_by_id != sales_id.to_i
            console_log(
              "Updating quoted_by_id for request #{request.id} (#{quoted_by_id.inspect} => #{sales_id})"
            )
            request.update_column :quoted_by_id, sales_id
          end
          sales_id ||= quoted_by_id

          created_at = order.created_at.to_date

          total = SalesTotal.where(sold_on: created_at,
                                   salesperson_id: sales_id).first_or_create
          total.order_total += order.total_price.to_f.round(2)
          total.order_count += 1
          total.save!
        end
      end

      def update_conversion_rates(date_range)
        epoch_range = date_range.begin.to_i..date_range.end.to_i
        console_log "Updating box counts from last #{MONTHS_TEXT}"
        done = false
        page = 1
        total_boxes = 0
        initial_count = Request.where.not(contacted_by_id: nil).count

        until done
          boxes = MostlyStreak::Box.all_with_limits({ limit: "1000", page: page.to_s, sortBy: "creationTimestamp" })

          boxes.each do |box|
            epoch = box.creation_timestamp / 1000
            (done = true) && break unless epoch_range === epoch
            created_at = Time.at(epoch)

            total_boxes += 1
            next unless box.salesperson

            customer_email = box.name.strip.downcase
            box.salesperson.claim_requests_with_email(customer_email, created_at - 1.day)
            sales_total = SalesTotal.where(sold_on: created_at.to_date,
                                           salesperson_id: box.salesperson.id).first_or_create
            sales_total.update_attribute :box_count, sales_total.box_count + 1
          end
          console_log "Processed #{page * 1000} boxes, last was on #{Time.at(boxes.last.creation_timestamp / 1000).to_date}"
          page += 1

        end
        final_count = Request.where.not(contacted_by_id: nil).count
        console_log "Updated salespeople for #{final_count - initial_count} requests based on #{total_boxes} boxes"
      end

      def console_log(message, level: :info)
        Rails.logger.send level, message
        return if Rails.env.test?
        puts "#{Time.now.to_s} #{message}"
      end
    end
  end
end
