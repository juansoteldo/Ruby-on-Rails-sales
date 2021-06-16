require 'campaign_monitor'

namespace :export do
  
  desc "Export fresh marketing emails to CM list"
  task fresh_users_to_cm: :environment do

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

end