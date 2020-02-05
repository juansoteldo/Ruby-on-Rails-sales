require "sidekiq/worker"

class SaveEmailJob < ApplicationJob
  def perform(args)
    @salesperson = Salesperson.find_by_email!(args[:from])
    @salesperson.claim_requests_with_email(args[:from])

    box = MostlyStreak::Box.find_by_email(args[:to])
    if box
      current_stage = MostlyStreak::Stage.find(key: box.stage_key)

      if current_stage.name == 'Leads'
        MostlyStreak::Box.set_stage(box.key, 'Contacted')
      end

      user_key = @salesperson&.user_key
      user_key ||= MostlyStreak::User.find_by_email(args[:from])

      if user_key
        MostlyStreak::Box.add_follower(@salesperson.streak_api_key, box.key, user_key)
      else
        Rails.logger.error ">>> Cannot get streak follower key for `#{args[:from]}`"
      end
    end
  end
end