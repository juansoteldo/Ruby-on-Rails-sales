desc "This task is called by the Heroku scheduler add-on"
task :send_reminders => :environment do
  puts "Sending Reminders"
  quoted_stage = ENV['QUOTE_STAGE']
  deposited_stage = ENV['DEPOSIT_STAGE']
  boxes = Streak::Box.all(ENV['PIPE_ID']).select { |b| b.stage_key == quoted_stage and !b.last_email_from.include? 'customtattoodesign.ca' }
  boxes.each do |box|
  	time_sent = Time.at(box.last_email_received_timestamp.to_i/1000).to_date
  	first = 1.day.ago.to_date
  	second = 3.days.ago.to_date
  	third = 5.days.ago.to_date
  	email = box.last_email_from
		if time_sent == first
			BoxMailer.reminder_email(email)
		elsif time_sent == second
			BoxMailer.reminder_email(email)
		elsif time_sent == third
			BoxMailer.reminder_email(email)
		end
  end
  puts "done."
end