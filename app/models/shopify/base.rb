# frozen_string_literal: true

require 'shopify_api'

class Shopify::Base
  def initialize(source)
    @source = source
  end

  def method_missing(symbol, *args)
    @source.send(symbol, *args)
  end
end
