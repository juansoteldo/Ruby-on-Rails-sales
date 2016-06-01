require 'streak_api/base'

class StreakAPI::Box < StreakAPI::Base
	def self.all
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_box/all', expires_in: 1.minutes) do
			Streak::Box.all()
		end
	end
	def self.set_stage(box_id, stage_name)
		Streak.api_key = Rails.application.config.streak_api_key
		box = Streak::Box.find(box_id)
		new_stage = StreakAPI::Stage.find_by_pipeline_name("CTD Sales", name: stage_name)
		Streak::Box.update(box_id, stageKey: new_stage.key)
	end
	def self.get_stage(box_id)
		Streak.api_key = Rails.application.config.streak_api_key
		box = Streak::Box.find(box_id)
		StreakAPI::Stage.find_by_pipeline_name("CTD Sales", key: box.stage_key)
	end
	def self.add_follower(box_id, follower_key)
		Streak.api_key = Rails.application.config.streak_api_key
		box = Streak::Box.find(box_id)
		follower_keys = box.follower_keys | [follower_key]
		Streak::Box.update(box_id, followerKeys: follower_keys)
	end
	def self.find_by_email(email)
		Streak.api_key = Rails.application.config.streak_api_key
		Streak::Box.all().select{|box| 
			box.name == email
		}.first
	end
end