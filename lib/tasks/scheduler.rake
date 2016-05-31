desc "This task is called by the Heroku scheduler add-on"
task :send_reminders => :environment do
  puts "Sending Reminders UPDATED"
  Streak.api_key = ENV['STREAK_API_KEY']
  quoted_stage = ENV['QUOTE_STAGE']
  deposited_stage = ENV['DEPOSIT_STAGE']
  boxes = Streak::Box.all(ENV['PIPE_ID']).select { |b| b.stage_key == quoted_stage and b.total_number_of_emails == 2 }
  boxes.each do |box|
  	time_sent = Time.at(box.last_email_received_timestamp.to_i/1000).to_date
  	email = box.last_email_from
		if time_sent == 2.days.ago.to_date
			BoxMailer.reminder_email(email).deliver_now
		end
    BoxMailer.reminder_email(email).deliver_now
  end
  puts "done."
end
#and !b.last_email_from.include? 'customtattoodesign.ca'