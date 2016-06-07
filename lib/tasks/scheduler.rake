desc "This task is called by the Heroku scheduler add-on"
task :send_reminders => :environment do
  puts "Sending Reminders"
  quoted_stage = StreakAPI::Stage.find_by_pipline_name("Sales / CRM", {name: "Contacted"})
  boxes = Streak::Box.all().select { |b| b.stage_key == quoted_stage.key }
  boxes.each do |box|
  	time_sent = Time.at(box.last_email_received_timestamp.to_i/1000).to_date
  	email = box.first_email_from
		if time_sent == 2.days.ago.to_date
			BoxMailer.reminder_email(email).deliver_now
		end
  end
  puts "done."
end
#and !b.last_email_from.include? 'customtattoodesign.ca'