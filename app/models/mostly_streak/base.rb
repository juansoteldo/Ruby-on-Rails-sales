# frozen_string_literal: true

require 'streak-ruby'

module MostlyStreak
  class Base
    def initialize(source)
      @source = source
    end

    def method_missing(symbol, *args)
      Streak.api_key = Rails.application.config.streak_api_key
      @source.send(symbol, *args)
    end
  end
end
