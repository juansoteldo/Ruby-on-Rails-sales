require 'streak_api/base'

class StreakAPI::Box
	def all
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_box/all', expires_in: 1.minutes) do
			Streak::Box.all()
		end
	end
end