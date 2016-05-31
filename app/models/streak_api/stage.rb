require 'streak_api/base'

class StreakAPI::Stage
	def all(pipline_key)
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_stage/all', expires_in: 1.minutes) do
			Streak::Stage.all(pipline_key)
		end
	end
	def all_by_pipline_name(pipline_name)
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_stage/all', expires_in: 1.minutes) do
			pipeline = Streak::Pipeline.select {|pl| pl.name == pipeline_name }
			Streak::Stage.all(pipeline.first.key)
		end
	end
	def find_by_pipline_name(pipline_name, param = {})
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_stage/all', expires_in: 1.minutes) do
			pipeline = Streak::Pipeline.select {|pl| pl.name == pipeline_name }
			key = param.keys.first.to_s
			Streak::Stage.all(pipeline.first.key).select{|stage| stage[key] == param[key]}
		end
	end
end