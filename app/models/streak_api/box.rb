require 'streak_api/base'

class StreakAPI::Box < StreakAPI::Base

	def self.all
		Rails.cache.fetch('streak_box/all', expires_in: 2.minutes) do
			Streak.api_key = Rails.application.config.streak_api_key
			Streak::Box.all()
		end
	end

	def self.query(query)
		Rails.cache.fetch('streak_box/query'+query, expires_in: 30.seconds) do
			Streak.api_key = Rails.application.config.streak_api_key
			results = Streak::Search.query(query).results
			results && results.boxes || [{}]
		end
	end

	def self.find(box_id)
		Streak.api_key = Rails.application.config.streak_api_key
		Streak::Box.find(box_id)
	end

	def self.find_by_email(email)
		return unless email =~ /\A[^@]+@[^@]+\Z/
		StreakAPI::Box.query(email).select{ |box|
			box.try(:name) && box.name.downcase == email.downcase
		}.last
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
	end

end
