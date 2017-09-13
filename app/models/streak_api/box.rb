# frozen_string_literal: true

require "streak_api/base"

class StreakAPI::Box < StreakAPI::Base
  def self.all
    Rails.cache.fetch("streak_box/all", expires_in: 2.minutes) do
      Streak.api_key = Rails.application.config.streak_api_key
      Streak::Box.all(ENV['STREAK_PIPELINE_ID'])
    end
  end

  def self.all_with_limits(params = { limit: "10", page: "1" } )
    Rails.cache.fetch("streak_box/all/#{params[:limit]}/#{params[:page]}", expires_in: 2.minutes) do
      Streak.api_key = Rails.application.config.streak_api_key
      Streak::Box.all ENV['STREAK_PIPELINE_ID'], params
    end
  end

  def self.query(query)
    Rails.cache.fetch("streak_box/query/" + query, expires_in: 10.seconds) do
      Streak.api_key = Rails.application.config.streak_api_key
      results = Streak::Search.query(query).results
      puts "Ran query with '#{query}', got #{results && results.boxes.count || '0'} boxes"
      results && results.boxes || [{}]
    end
  end

  def self.find(box_id)
    Streak.api_key = Rails.application.config.streak_api_key
    Streak::Box.find(box_id)
  end

  def self.find_by_email(email)
    return unless email =~ /\A[^@]+@[^@]+\Z/
		Streak.api_key = Rails.application.config.streak_api_key
		box_id = StreakAPI::Box.query(email).select do |box|
      box.name.casecmp(email.downcase).zero?
    end.last.try(&:box_key)

    box_id && Streak::Box.find(box_id) || nil
  end

  def self.set_stage(box_id, stage_name)
    new_stage = StreakAPI::Stage.find(name: stage_name)

    Streak.api_key = Rails.application.config.streak_api_key
    Streak::Box.update(box_id, stageKey: new_stage.key)
  end

  def self.add_follower(user_api_key, box_id, follower_key)
    # has to be user specific
    Streak.api_key = user_api_key
    box = Streak::Box.find(box_id)
    follower_keys = box.follower_keys | [follower_key]
    Streak::Box.update(box_id, followerKeys: follower_keys)
  rescue
    Rails.logger.warn "Could not add follower with key `#{follower_key}` to box `#{box_id}`"
  end
end
