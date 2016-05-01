class OrdersCreateJob < ActiveJob::Base
  queue_as :webhook
  def perform(params)
  	Streak.api_key = ENV['STREAK_API_KEY']
    order = ShopifyAPI::Order.new(params[:webhook])
		email = order.customer.email
		is_deposit? = order.line_items.any?{|line_item| line_item.title.include? "Deposit" }
		is_final? = order.line_items.any?{|line_item| line_item.title.include? "Final" }
		order.note_attributes.each do |note_attr|
			if note_attr.name == "req_id"
				@req_id = note_attr.value
			end
		end
		if is_deposit?
			quoted_stage = ENV['QUOTE_STAGE']
			deposited_stage = ENV['DEPOSIT_STAGE']
			boxes = Streak::Box.all(ENV['STREAK_PIPELINE_ID']).select { |b| b.email_addresses.include? email and b.stage_key == quoted_stage and b.total_number_of_sent_emails >= 1 }
			boxes.each do |box|
				Streak::Box.update(box.box_key, {stageKey: deposited_stage})
			end
      if @req_id
      	request = Request.find(@req_id)
      	request.update_attribute(:deposit_order_id, order.id)
      end
		end
		if is_final?
      if @req_id
      	request = Request.find(@req_id)
      	request.update_attribute(:final_order_id, order.id)
      end
		end
  rescue Resque::TermException
    Resque.enqueue(self, key)
  end
end