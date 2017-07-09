# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
set :output, File.expand_path( '../log/cron.log', File.dirname(__FILE__) )


every 1.day, at: '13:30' do
  rake 'send_reminders'
end


every 1.day, at: '00:00' do
  rake 'update_sales_totals'
end