# frozen_string_literal: true

class SaveEmailJob < ApplicationJob
  retry_on Streak::APIError, wait: 15.seconds, attempts: 6

  def perform(args)
    @salesperson = args[:salesperson]
    @salesperson.claim_requests_with_email(args[:recipient_email])
    start = Time.now
    box = nil
    while (Time.now - start < 10.seconds) do
      box = MostlyStreak::Box.find_by_name(args[:recipient_email])
      break unless box.nil?
      sleep 2
    end
    return unless box

    current_stage = MostlyStreak::Stage.find(key: box.stage_key)

    if current_stage.name == "Leads"
      box = box.set_stage("Contacted")
    end

    user_key = @salesperson&.user_key
    user_key ||= MostlyStreak::User.find_by_email(@salesperson.email)

    if user_key
      box.add_follower(user_key, @salesperson.streak_api_key)
    else
      Rails.logger.error ">>> Cannot get streak follower key for `#{@salesperson.email}`"
    end
  end
end