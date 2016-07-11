require 'streak_api/base'

class StreakAPI::Box < StreakAPI::Base

	def self.all
		Rails.cache.fetch('streak_box/all', expires_in: 1.minutes) do
			Streak.api_key = Rails.application.config.streak_api_key
			Streak::Box.all()
		end
	end

	def self.find(box_id)
		Streak.api_key = Rails.application.config.streak_api_key
		Streak::Box.find(box_id)
	end

	def self.find_by_email(email)
		StreakAPI::Box.all.select{ |box|
			box.name == email
		}.first
	end

	def self.set_stage(box_id, stage_name)

		new_stage = StreakAPI::Stage.find(name: stage_name)

		Streak.api_key = Rails.application.config.streak_api_key
		Streak::Box.update(box_id, stageKey: new_stage.key)
	end

	def self.get_stage(box_id)
		box = StreakAPI::Box.find(box_id)
		StreakAPI::Stage.find(key: box.stage_key)
	end

	def self.add_follower(user_api_key, box_id, follower_key)
		# has to be user specific
		Streak.api_key = user_api_key
		box = Streak::Box.find(box_id)
		follower_keys = box.follower_keys | [follower_key]
		Streak::Box.update(box_id, followerKeys: follower_keys)
	end

end
