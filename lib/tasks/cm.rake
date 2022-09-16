# require 'csv'
# require 'open-uri'
# require 'services/campaign_monitor'

namespace :cm do
  
  desc "Export fresh user emails to 2 CampaignMonitor lists"
  task export_fresh_users: :environment do

    threshold_date = DateTime.parse '2020-11-20'

    query = User.where('updated_at > ?', threshold_date)
      .includes(:requests)

    query.find_each.with_index do |user, index|
      Services::CampaignMonitor.add_user_to_all_list(user)
      Services::CampaignMonitor.add_user_to_marketing_list(user) if user.marketing_opt_in?
    end
  end

  # TODO: failing test
  # desc "Back sync suppression list with db users"
  # task back_sync_suppressions: :environment do

  #   threshold_date = DateTime.parse '2020-11-20'

  #   TODO: get supression list through API
  #   https://www.campaignmonitor.com/api/v3-3/clients/#getting-suppression-list
  #   https://api.createsend.com/api/v3.3/clients/{clientid}/suppressionlist.{xml|json}?page={page}&pagesize={pagesize}&orderfield={email|date}&orderdirection={asc|desc}

  #   csv_text = open(Rails.application.credentials.suppressions_url.to_s) # broken link
  #   csv = CSV.parse(csv_text, headers: true)

  #   csv.each do |row|
  #     email     = row[0]
  #     date_txt  = row[1]

  #     next if DateTime.parse(date_txt) < threshold_date

  #     user = User.find_by_email(email)
  #     next unless user

  #     user.update(marketing_opt_in: false)
  #   end
  # end

  desc "Sync unsubscribed users with All Emails CampaignMonitor list"
  task sync_falsed_presales_opt_in: :environment do

    Rails.logger.info "Total: #{User.where(presales_opt_in: false).count}"
    User.where(presales_opt_in: false).find_each.with_index do |user, index|
      Services::CampaignMonitor.remove_user_from_all_list(user)
      Rails.logger.info "synced #{index} users" if (index % 100).zero?
    end
  end  

  desc 'Add transactional emails from credentials'
  task add_transactional_emails: :environment do
    transactional_emails = Rails.application.credentials[:cm][:transactional_emails]
    TransactionalEmail.delete_all
    transactional_emails.each do |key, value|
      TransactionalEmail.create({
        name: key,
        smart_id: value
      })
    end
    Rails.logger.info 'Transactional emails added.'
  end
end