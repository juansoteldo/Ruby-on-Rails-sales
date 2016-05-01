desc "This task is called by the Heroku scheduler add-on"
task :send_reminders => :environment do
  puts "Sending Reminders"
  quoted_stage = ENV['QUOTE_STAGE']
  deposited_stage = ENV['DEPOSIT_STAGE']
  boxes = Streak::Box.all(ENV['PIPE_ID']).select { |b| b.stage_key == quoted_stage and !b.last_email_from.includes? 'customtattoodesign.ca' }
  boxes.each do |box|
  	stage_key = box.stage_key == quoted_stage ? deposited_stage : box.stage_key
  	Streak::Box.update(box.box_key, {stageKey: stage_key})
  end
  NewsFeed.update
  puts "done."
end