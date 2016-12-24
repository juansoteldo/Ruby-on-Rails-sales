desc 'This task is called by cron'
task :send_reminders => :environment do
  include ActionView::Helpers::DateHelper

  puts 'Sending Reminders'

  counts = MarketingEmail.all.map do |me|
    { id: me.id, name: me.template_name, count: 0 }
  end

  maximum_age = MarketingEmail.all.order( :days_after_state_change ).last.days_after_state_change
  cutoff = [maximum_age.days.ago.beginning_of_day, Time.parse('2016-10-01  00:00:00 GMT-4' )].max
  maximum_age = ((Time.zone.now - cutoff)/1.day).to_i

  puts "Fetching orders for last #{maximum_age} days"

  orders = Shopify::Order.find( { created_at_min: cutoff, limit: 250 } )
  puts "Updating requests for #{orders.count} orders"
  orders.each do |order|
    order.update_request
  end

  requests = Request.joins(:user).where('requests.created_at > ? AND state_changed_at BETWEEN ? AND ?',
                                        cutoff, cutoff, Time.zone.now.beginning_of_day).where("quoted_by_id IS NOT NULL")
  puts "Processing #{requests.count} requests"
  requests.each do |request|
    puts "  Examining request #{request.id}, it's #{time_ago_in_words(request.state_changed_at)} old, and is `#{request.state}`"
    marketing_emails = MarketingEmail.order('days_after_state_change').
        where( 'days_after_state_change * 24 < ? AND state LIKE ?',
               request.hours_since_state_change, "%#{request.state}%" )

    next unless marketing_emails.any?
    if request.user.opted_out
      puts 'User has opted out, skipping.'
      next
    end

    puts "    #{marketing_emails.count} marketing emails are appropriate"
    delivered_emails = request.delivered_emails.where(marketing_email_id: marketing_emails.last.id)
    if delivered_emails.any?
      puts "    The email has already been sent at #{delivered_emails.last.created_at}"
      next
    end

    marketing_email = marketing_emails.last
    puts "    Sending marketing email `#{marketing_email.template_name}` to `#{request.user.email}`"
    BoxMailer.marketing_email(request, marketing_email).deliver_now
    request.delivered_emails.create(
      marketing_email_id: marketing_email.id, request_id: request.id, sent_at: Time.now
    )
    counts[counts.find_index{|c| c[:id] == marketing_email.id }][:count] += 1
  end
  puts 'Done.'
  counts.each do |count|
    puts "#{count[:name]}: #{count[:count]}"
  end
  AdminMailer.daily_blast_counts(counts).deliver_now

end

require 'action_view'
require 'action_view/helpers'
