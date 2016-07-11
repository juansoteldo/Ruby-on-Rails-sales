require 'streak_api/base'

class StreakAPI::Pipeline < StreakAPI::Base

	def self.all
		Rails.cache.fetch('streak_pipline/all', expires_in: 15.minutes) do
			Streak.api_key = Rails.application.config.streak_api_key
			Streak::Pipeline.all()
		end
	end

	def self.default
		StreakAPI::Pipeline.all.select{
				|p| p.name == 'CTD Sales'
		}.first
	end

	def self.user_keys
		StreakAPI::Pipeline.default.acl_entries.map { |u|
			u.user_key
		}
	end
end
