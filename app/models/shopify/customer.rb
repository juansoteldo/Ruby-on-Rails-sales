require 'shopify/base'

class Shopify::Customer < Shopify::Base
  def self.search(params)
    ShopifyAPI::Customer.search(params).map{ |c| self.new(c) }
  end

  def self.all
    ShopifyAPI::Customer.all.map{ |c| self.new(c) }
  end

  def orders
    @source.orders.map{|v| Shopify::Order.new(v)}
  end

end

