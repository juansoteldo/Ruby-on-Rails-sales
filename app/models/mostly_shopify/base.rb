# frozen_string_literal: true

require "shopify_api"

module MostlyShopify
  # The base class for MostlyShopify classes
  class Base
    attr_accessor :source

    def initialize(source)
      @source = source
    end

    def method_missing(symbol, *args)
      if symbol == :customer
        if defined?(@source.customer)
          @source.customer
        end
      else
        @source.send(symbol, *args)
      end
    end

    def self.expire_in(default = 5.minutes)
      Rails.env.production? ? default : 1.days
    end
  end
end
