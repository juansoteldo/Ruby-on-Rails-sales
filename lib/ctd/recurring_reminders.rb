# frozen_string_literal: true

require "action_view/helpers"

module CTD
  # Sends MarketingEmails where applicable to recent requests
  class RecurringReminders
    attr_accessor :counts, :console

    def initialize(scope, console: true)
      @console = console
      @scope = scope
      @counts = scope.map do |marketing_email|
        {
          id: marketing_email.id,
          name: marketing_email.template_name,
          count: 0
        }
      end
      puts "Initialized RecurringReminders for last #{maximum_days} days"
    end

    def deliver_outstanding!
      update_requests!
      puts "Sending reminders for #{requests.count} requests"
      requests.each do |request|
        puts_log "Is #{request.decorate.age_in_words} old, and is `#{request.state}`", request
        marketing_email = @scope.last_reminder_for_request(request)
        next unless marketing_email

        puts_log "#{marketing_email} is appropriate", request
        deliver_email marketing_email, request
      end
    end

    def log_counts(email: true)
      puts "Recurring Reminder Counts:"
      @counts.each do |count|
        puts "  #{count[:name]}: #{count[:count]}"
      end
      AdminMailer.daily_blast_counts(@counts).deliver_later if email
    end

    private

    def update_requests!
      puts_log "Updating requests for #{orders.count} orders"
      orders.each(&:update_request!)
    end

    def deliver_email(marketing_email, request)
      previously_delivered = request.delivered_emails.where(marketing_email: marketing_email)
      if previously_delivered.any?
        puts_log "#{marketing_email} has already been sent at #{previously_delivered.last.created_at}", request
        return
      end

      if request.delivered_emails.create(marketing_email: marketing_email, request: request).sent_at
        puts_log "Sent `#{marketing_email}`", request
        increment_counter marketing_email
      else
        puts_log "User has opted out, skipping.", request
      end
    end

    def increment_counter(marketing_email)
      @counts[@counts.find_index { |c| c[:id] == marketing_email.id }][:count] += 1
    end

    def requests
      @requests ||= Request.quoted.created_or_changed_between(cutoff, Time.zone.now.beginning_of_day).joins(:user)
    end

    def orders
      @orders ||= MostlyShopify::Order.find(created_at_min: cutoff, limit: 250)
    end

    def cutoff
      return @cutoff unless @cutoff.nil?

      maximum_age = @scope.maximum(:days_after_state_change) + 1
      @cutoff = [maximum_age.days.ago.beginning_of_day, Time.parse("2016-10-01  00:00:00 GMT-4")].max
    end

    def maximum_days
      ((Time.zone.now - cutoff) / 1.day).to_i
    end

    def puts_log(message, object = nil)
      message = "#{object}: #{message}" if object
      Rails.logger.info message
      puts message if @console
    end
  end
end