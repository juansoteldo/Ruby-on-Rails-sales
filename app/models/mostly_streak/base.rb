# frozen_string_literal: true

# rubocop:disable Style/MethodMissingSuper

require "streak-ruby"

module MostlyStreak
  class Base
    def initialize(source)
      @source = source
    end

    def method_missing(symbol, *args)
      Streak.api_key = Settings.streak.api_key
      @source.send(symbol, *args)
    end
  end
end
