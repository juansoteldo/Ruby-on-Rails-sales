class OrdersCreateJob < ActiveJob::Base
  queue_as :webhook

  def perform(params)
    Streak.api_key = Rails.application.config.streak_api_key

    order = ShopifyAPI::Order.new(params[:webhook])
    email = order.customer.email.downcase
    is_deposit = order.line_items.any? { |line_item| line_item.title.include? "Deposit" }
    is_final = order.line_items.any? { |line_item| line_item.title.include? "Final" }

    if order.note_attributes
      order.note_attributes.each do |note_attr|
        if note_attr.name == "req_id"
          @req_id = note_attr.value
        end
        if note_attr.name == "sales_id"
          @sales_id = note_attr.value
        end
      end
    end

    if is_deposit
      StreakAPI::Box.all.select do |b|
        b.email_addresses.include? email
      end.each do |box|
        StreakAPI::Box.set_stage(box.box_key, "Deposited")
      end

      if @req_id && @req_id != "undefined"
        request = Request.find(@req_id)
        request.update_attribute(:deposit_order_id, order.id)
      end

      BoxMailer.confirmation_email(email).deliver_now
    end

    if is_final
      if @req_id && @req_id != "undefined"
        request = Request.find(@req_id)
        request.update_attribute(:final_order_id, order.id)
        BoxMailer.final_confirmation_email(email).deliver_now
      end
    end

    # if @sales_id && @req_id
    #   Order.create(salesperson_id: @sales_id, total_price: , subtotal_price: , customer_email:,)
    # end
  end
end

require 'streak_api/box'
