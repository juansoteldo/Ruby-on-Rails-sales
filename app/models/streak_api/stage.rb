require 'streak_api/base'

class StreakAPI::Stage < StreakAPI::Base
	def self.all(pipline_key)
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_stage/all', expires_in: 1.minutes) do
			Streak::Stage.all(pipline_key)
		end
	end
	def self.all_by_pipeline_name(pipeline_name)
		Streak.api_key = Rails.application.config.streak_api_key
		Rails.cache.fetch('streak_stage/all', expires_in: 1.minutes) do
			pipelines = Streak::Pipeline.all().select {|pl| pl.name == pipeline_name }
			if pipelines.any?
				Streak::Stage.all(pipelines.first.key)
			end
		end
	end
	def self.find_by_pipeline_name(pipeline_name, param = {})
		Streak.api_key = Rails.application.config.streak_api_key
		pipelines = Streak::Pipeline.all().select {|pl| pl.name == pipeline_name }
		if pipelines.any?
			param_key = param.keys.first.to_s
			Streak::Stage.all(pipelines.first.key).instance_values["values"].each{|key, val| 
				if val.send(param_key).to_s == param[param_key.to_sym]
					return val
				end
			}
		end
	end
	def self.find(param = {})
		Streak.api_key = Rails.application.config.streak_api_key
		param_key = param.keys.first.to_s
		Streak::Stage.all(ENV['STREAK_PIPELINE_ID']).instance_values["values"].each{|key, val| 
			if val.send(param_key).to_s == param[param_key.to_sym]
				return val
			end
		}
	end
end