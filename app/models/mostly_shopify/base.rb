# frozen_string_literal: true

# rubocop:disable Style/MethodMissingSuper

require "shopify_api"

module MostlyShopify
  # The base class for MostlyShopify classes
  class Base
    attr_accessor :source

    def initialize(source)
      @source = source
    end

    def method_missing(symbol, *args)
      @source.send(symbol, *args)
    end

    def self.expire_in(default = 5.minutes)
      Rails.env.production? ? default : 1.days
    end
  end
end
