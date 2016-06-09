desc "This task is called by the Heroku scheduler add-on"
task :send_reminders => :environment do
  puts "Sending Reminders"
  orders = ShopifyAPI::Order.find( :all, :params => {created_at_min: 3.days.ago.beginning_of_day} )
  emails = orders.map{ |ord| ord.customer.email }
  requests = Request.where("? <= created_at AND created_at <= ?", 2.days.ago.beginning_of_day, 2.days.ago.end_of_day)
  requests.each do |request|
    unless request.delivered_emails.where(marketing_email_id: 1).any?
      email = request.user.email
      unless emails.include? email
        puts "#{email}"
        #BoxMailer.reminder_email(email).deliver_now
        #request.delivered_emails.create(sent_at: Time.now, marketing_email_id: 1, request_id: request.id)
      end
    end
  end
  puts "done."
  # quoted_stage = StreakAPI::Stage.find_by_pipline_name("Sales / CRM", { name: "Contacted" })
  # boxes = Streak::Box.all().select { |b| b.stage_key == quoted_stage.key }
  # boxes.each do |box|
  # 	time_sent = Time.at(box.last_email_received_timestamp.to_i/1000).to_date
  # 	email = box.first_email_from
		# if time_sent == 2.days.ago.to_date
		# 	BoxMailer.reminder_email(email).deliver_now
		# end
  # end
end
#and !b.last_email_from.include? 'customtattoodesign.ca'
#