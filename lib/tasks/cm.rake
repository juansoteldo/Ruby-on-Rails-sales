require 'campaign_monitor'
require 'csv'

namespace :cm do
  
  desc "Export fresh user emails to 2 CM lists"
  task export_fresh_users: :environment do

    threshold_date = DateTime.parse '2020-11-20'

    query = User.where('updated_at > ?', threshold_date)
      .includes(:requests)

    query.find_each.with_index do |user, index|
      CampaignMonitor.add_user_to_all_list(user)
      CampaignMonitor.add_user_to_marketing_list(user) if user.marketing_opt_in?
      print '.' if (index % 25).zero?
    end
    puts "\n"
  end

  desc "Back sync suppression list with db users"
  task back_sync_suppressions: :environment do

    threshold_date = DateTime.parse '2020-11-20'

    CSV.foreach("lib/csv/suppressions.csv") do |row|
      email     = row[0]
      date_txt  = row[1]
      reason    = row[2]

      next if DateTime.parse(date_txt) < threshold_date

      user = User.find_by_email(email)
      next unless user

      user.update(marketing_opt_in: false)
      print '.'
    end

    puts "\n"
  end

end