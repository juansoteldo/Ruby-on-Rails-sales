# frozen_string_literal: true

# Saves an email based on data from Chrome extension
class SaveEmailJob < ApplicationJob
  StreakBoxNotFoundError = Class.new(StandardError)
  retry_on Streak::APIError, wait: 15.seconds, attempts: 6
  retry_on StreakBoxNotFoundError, wait: 10, attempts: 1

  TIME_TO_WAIT_FOR_BOX = Rails.env.test? ? 30 : 10

  def perform(args)
    attempt = 0
    @salesperson = args[:salesperson]
    @salesperson.claim_requests_with_email(args[:recipient_email])
    return unless User.find_by_email(args[:recipient_email])
    return unless Request.newer_than_days(180).matching_email(args[:recipient_email]).any?

    start = Time.now
    box = nil
    while Time.now - start < TIME_TO_WAIT_FOR_BOX.seconds
      email = args[:recipient_email].downcase
      box = MostlyStreak::Box.query(email).sort_by { |e| -e.creation_timestamp }.first
      break unless box.nil?
      sleep 1
    end

    raise StreakBoxNotFoundError, "Cannot find streak box, aborting" if box.nil?

    box.set_stage_by_name('Contacted') if ['Fresh', 'Leads'].include?(box.current_stage.name)
    box.add_follower(@salesperson.user_key, @salesperson.streak_api_key) if @salesperson.user_key
  end
end
