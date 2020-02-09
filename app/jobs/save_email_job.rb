# frozen_string_literal: true

class SaveEmailJob < ApplicationJob
  retry_on Streak::APIError, wait: 15.seconds, attempts: 6

  def perform(args)
    box = MostlyStreak::Box.find_by_email(args[:to])
    @salesperson = args[:salesperson]
    @salesperson.claim_requests_with_email(args[:recipient_email])
    return unless box

    current_stage = MostlyStreak::Stage.find(key: box.stage_key)

    if current_stage.name == 'Leads'
      MostlyStreak::Box.set_stage(box.key, 'Contacted')
    end

    user_key = @salesperson&.user_key
    user_key ||= MostlyStreak::User.find_by_email(@salesperson.email)

    if user_key
      MostlyStreak::Box.add_follower(@salesperson.streak_api_key, box.key, user_key)
    else
      Rails.logger.error ">>> Cannot get streak follower key for `#{@salesperson.email}`"
    end
  end
end