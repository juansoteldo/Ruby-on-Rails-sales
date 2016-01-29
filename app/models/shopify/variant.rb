require 'shopify/base'

class Shopify::Variant < Shopify::Base
  def has_color?
    is_gift_card? && false || (@source.option1 == 'yes')
  end

  def has_cover_up?
    is_gift_card? && false || (@source.option2 == 'yes')
  end

  def is_gift_card?
    fulfillment_service == 'gift_card'
  end

  def self.find(id)
    self.shopify_sources.select{|i| i.id = id }.map{ |i| self.new(i) }
  end

  def self.all
    self.shopify_sources.map{ |i| self.new(i) }
  end

  def self.shopify_sources
    Rails.cache.fetch(expires_in: 5.minutes) do
      ShopifyAPI::Variant.all
    end
  end
end
