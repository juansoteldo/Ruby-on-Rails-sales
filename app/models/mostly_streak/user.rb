# frozen_string_literal: true

require 'mostly_streak/base'
require "mostly_streak/pipeline"

module MostlyStreak
  class User < Base
    def self.find(key)
      Rails.cache.fetch('streak_user/' + key, expires_in: 15.minutes) do
        Streak.api_key = Settings.streak.api_key
        Streak::User.find(key)
      end
    end

    def self.find_by_email(email)
      Pipeline.user_keys.select do |k|
        user = find(k)
        user.email == email
      end.first
    end
  end
end
