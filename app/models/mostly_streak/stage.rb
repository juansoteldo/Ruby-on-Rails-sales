# frozen_string_literal: true

require "mostly_streak/base"

module MostlyStreak
  class Stage < Base
    def self.all
      Rails.cache.fetch("streak_stage/all", expires_in: 1.hours) do
        Streak.api_key = Settings.streak.api_key
        Streak::Stage.all(Settings.streak.pipeline_key)
      end
    end

    def self.find(param = {})
      param_key = param.keys.first.to_s

      all.instance_values["values"].each do |_key, val|
        return val if val.send(param_key).to_s == param[param_key.to_sym]
      end
    end

    def self.contacted
      Rails.cache.fetch("streak_stage/contacted", expires_in: 1.hour) do
        find(name: "Contacted")
      end
    end

    def self.leads
      Rails.cache.fetch("streak_stage/leads", expires_in: 1.hour) do
        find(name: "Leads")
      end
    end

    def self.fresh
      Rails.cache.fetch("streak_stage/fresh", expires_in: 1.hour) do
        find(name: "Fresh")
      end
    end

    def self.quoted
      Rails.cache.fetch("streak_stage/fresh", expires_in: 1.hour) do
        find(name: "Quoted")
      end
    end
  end
end
