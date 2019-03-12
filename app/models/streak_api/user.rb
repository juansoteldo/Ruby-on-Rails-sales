# frozen_string_literal: true

require 'streak_api/base'

class StreakAPI::User < StreakAPI::Base
  def self.find(key)
    Rails.cache.fetch('streak_user/' + key, expires_in: 15.minutes) do
      Streak.api_key = Rails.application.config.streak_api_key
      Streak::User.find(key)
    end
  end

  def self.find_by_email(email)
    StreakAPI::Pipeline.user_keys.select do |k|
      user = StreakAPI::User.find(k)
      user.email == email
    end.first
  end
end
