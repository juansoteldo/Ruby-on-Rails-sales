require 'streak_api/base'

class StreakAPI::User < StreakAPI::Base
	def self.find(key)
		Streak.api_key = Rails.application.config.streak_api_key
		Streak::User.find(key)
	end
	def self.find_key_by_email(email)
		StreakAPI::Pipeline.user_keys.select{ |k|
			user = Streak::User.find(k)
			user.email == email
		}.first
	end
end