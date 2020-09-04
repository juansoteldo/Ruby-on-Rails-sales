# frozen_string_literal: true

namespace :recurring do
  desc "Add gmail threads to streak boxes"
  task associate_gmail_threads: :environment do
    return unless Settings.streak.create_boxes

    CTD::GmailScanner.associate_threads
  end

  desc "Updates total sales"
  task update_sales_totals: :environment do
    3.times do
      break if CTD::SalesUpdater.update

      sleep_duration = Rails.env.production? ? 30 : 5
      puts "Update failed, sleeping for #{sleep_duration} seconds"
      sleep sleep_duration
    end
  end

  desc "Sends all outstanding reminders"
  task send_reminders: :environment do |_task, args|
    scope = if args.extras.count.positive?
              MarketingEmail.where(template_name: args.extras.first)
            else
              MarketingEmail.all
            end
    reminders = CTD::RecurringReminders.new(scope)
    reminders.deliver_outstanding!
    reminders.log_counts(email: true)
  end
end
