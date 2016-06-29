require 'streak_api/base'

class StreakAPI::Pipeline < StreakAPI::Base
	def self.all
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_pipline/all', expires_in: 1.minutes) do
			Streak::Pipeline.all()
		end
	end
	def self.find_by_name pipeline_name
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_pipline/find', expires_in: 1.minutes) do
			Streak::Pipeline.all().select{|p| p.name == pipeline_name}.first
		end
	end
	def self.user_keys
		StreakAPI::Pipeline.find_by_name("CTD Sales").acl_entries.map{|u| u.user_key}
	end
end