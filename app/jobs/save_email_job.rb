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
    begin
      attempt += 1
      while Time.now - start < TIME_TO_WAIT_FOR_BOX.seconds
        box = MostlyStreak::Box.find_by_name(args[:recipient_email])
        break unless box.nil?

        sleep 2
      end

      raise StreakBoxNotFoundError, "Cannot find streak box, aborting" if box.nil?
    rescue StreakBoxNotFoundError
      return unless attempt < 4

      sleep 1 # wait a bit
      retry
    end
    current_stage = box.current_stage

    box.set_stage("Contacted") if ["Fresh", "Leads"].include?(current_stage.name)
    box.assign_to_salesperson(@salesperson)
  end
end
