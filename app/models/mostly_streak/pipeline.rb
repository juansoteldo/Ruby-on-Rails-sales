# frozen_string_literal: true

require 'mostly_streak/base'

module MostlyStreak
  class Pipeline < Base
    def self.all
      Rails.cache.fetch('streak_pipline/all', expires_in: 15.minutes) do
        Streak.api_key = Settings.streak.api_key
        Streak::Pipeline.all
      end
    end

    def self.default
      all.select do |p|
        p.key == Settings.streak.pipeline_key
      end.first
    end

    def self.user_keys
      default.acl_entries.map do |u|
        u.user_key
      end
    end
  end
end
