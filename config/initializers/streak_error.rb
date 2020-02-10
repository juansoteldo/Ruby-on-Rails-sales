module Streak
  StreakError.class_eval do
    attr_reader :http_status, :http_body
  end
end