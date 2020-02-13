# frozen_string_literal: true

require "ctd/errors"

class SaveEmailJob < ApplicationJob
  retry_on Streak::APIError, wait: 15.seconds, attempts: 6
  TIME_TO_WAIT_FOR_BOX = Rails.env.test? ? 30 : 10

  def perform(args)
    @salesperson = args[:salesperson]
    @salesperson.claim_requests_with_email(args[:recipient_email])
    return unless User.find_by_email(args[:recipient_email])
    start = Time.now
    box = nil
    while Time.now - start < TIME_TO_WAIT_FOR_BOX.seconds
      box = MostlyStreak::Box.find_by_name(args[:recipient_email])
      break unless box.nil?
      sleep 2
    end

    raise CTD::Errors::StreakBoxNotFoundError, "Cannot find streak box, aborting" if box.nil?

    current_stage = MostlyStreak::Stage.find(key: box.stage_key)

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
