# frozen_string_literal: true

require 'streak_api/base'

class StreakAPI::Stage < StreakAPI::Base
  def self.all
    Rails.cache.fetch('streak_stage/all', expires_in: 15.minutes) do
      Streak.api_key = Rails.application.config.streak_api_key
      Streak::Stage.all(ENV['STREAK_PIPELINE_ID'])
    end
  end

  def self.find(param = {})
    param_key = param.keys.first.to_s

    StreakAPI::Stage.all.instance_values["values"].each do |key, val|
      if val.send(param_key).to_s == param[param_key.to_sym]
        return val
      end
    end
  end
end
