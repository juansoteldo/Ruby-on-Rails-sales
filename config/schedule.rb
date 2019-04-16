# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
set :output, File.expand_path( '../log/cron.log', File.dirname(__FILE__) )


every 1.day, at: '13:30' do
  rake 'recurring:send_reminders'
end


every 1.day, at: '03:00' do
  rake 'recurring:update_sales_totals'
end
