# frozen_string_literal: true

require 'streak-ruby'

module MostlyStreak
  class Base
    def initialize(source)
      @source = source
    end

    def method_missing(symbol, *args)
      @source.send(symbol, *args)
    end
  end
end
