require 'streak_api/base'

class StreakAPI::Pipeline
	def all
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_pipline/all', expires_in: 1.minutes) do
			Streak::Pipline.all()
		end
	end
end