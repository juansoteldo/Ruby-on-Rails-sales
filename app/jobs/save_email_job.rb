# frozen_string_literal: true

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
      if attempt < 4
        sleep 1  # wait a bit
        retry
      else
        return
      end
    end
    current_stage = box.current_stage

    box.set_stage("Contacted") if ["Fresh", "Leads"].include?(current_stage.name)

    user_key = @salesperson&.user_key
    user_key ||= MostlyStreak::User.find_by_email(@salesperson.email)

    if user_key
      box.add_follower(user_key, @salesperson.streak_api_key)
    else
      Rails.logger.error ">>> Cannot get streak follower key for `#{@salesperson.email}`"
    end
  end
end
