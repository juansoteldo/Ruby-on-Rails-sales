# frozen_string_literal: true

require 'mostly_shopify/base'

class MostlyShopify::Customer < MostlyShopify::Base
  def self.search(params)
    ShopifyAPI::Customer.search(params).map{ |c| self.new(c) }
  end

  def self.all
    ShopifyAPI::Customer.all.map{ |c| self.new(c) }
  end

  def orders
    @source.orders.map{|v| MostlyShopify::Order.new(v)}
  end
end
