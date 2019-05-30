# frozen_string_literal: true

require "mostly_streak/base"

module MostlyStreak
  class Box < Base
    # @param [MostlyGmail::Message] message
    def self.from_gmail_message(message)

    end

    def self.create(email)
      Streak::Box.create(ENV['STREAK_PIPELINE_ID'], { name: email })
    end

    def self.delete(box_key)
      Streak::Box.delete(box_key)
    end

    def self.all
      Rails.cache.fetch("streak_box/all", expires_in: 2.minutes) do
        Streak.api_key = Rails.application.config.streak_api_key
        Streak::Box.all(ENV['STREAK_PIPELINE_ID'])
      end
    end

    def self.all_with_limits(params = { limit: "10", page: "1" })
      Rails.cache.fetch("streak_box/all/#{params[:limit]}/#{params[:page]}", expires_in: 2.minutes) do
        Streak.api_key = Rails.application.config.streak_api_key
        Streak::Box.all ENV['STREAK_PIPELINE_ID'], params
      end
    end

    def self.query(query)
      Rails.cache.fetch("streak_box/query/" + query, expires_in: 10.seconds) do
        Streak.api_key = Rails.application.config.streak_api_key
        results = Streak::Search.query(query).results
        results&.boxes || [{}]
      end
    end

    def self.find(box_key)
      Streak.api_key = Rails.application.config.streak_api_key
      Streak::Box.find(box_key)
    end

    def self.find_by_email(email)
      return unless email =~ /\A[^@]+@[^@]+\Z/
      Streak.api_key = Rails.application.config.streak_api_key
      box_key = MostlyStreak::Box.query(email).select do |box|
        box.name.casecmp(email.downcase).zero?
      end.last.try(&:box_key)

      box_key && Streak::Box.find(box_key) || nil
    end

    def self.set_stage(box_key, stage_name)
      Streak.api_key = Rails.application.config.streak_api_key
      new_stage = MostlyStreak::Stage.find(name: stage_name)
      raise "cannot find stage key for `#{stage_name}`" unless new_stage
      Streak::Box.update(box_key, stageKey: new_stage.key)
    end

    def self.add_follower(user_api_key, box_key, follower_key)
      # has to be user specific
      Streak.api_key = user_api_key
      box = Streak::Box.find(box_key)
      follower_keys = box.follower_keys | [follower_key]
      Streak::Box.update(box_key, followerKeys: follower_keys)
    rescue
      Rails.logger.warn "Could not add follower with key `#{follower_key}` to box `#{box_key}`"
    end
  end
end
