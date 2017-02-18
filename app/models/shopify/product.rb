require 'shopify/base'

class Shopify::Product < Shopify::Base

  def self.find(id)
    self.shopify_sources.select{|i| i.id = id }.map{ |i| self.new(i) }
  end

  def self.all
    self.shopify_sources.map{ |i| self.new(i) }
  end

  def self.shopify_sources
    Rails.cache.fetch(expires_in: 1.minutes) do
      ShopifyAPI::Product.all
    end
  end

  def is_final_payment?
    handle.include?('final')
  end

  def is_deposit?
    handle.include?('deposit')
  end

  def variants
    @source.variants.map{|v| Shopify::Variant.new(v)}
  end

  def sub_title
    @source.title.sub( group_title, '' ).strip
  end

  def group_title
    title.sub( 'Final Payment', '' ).sub( 'Deposit', '').strip
  end


end

require 'shopify_api'
require 'shopify/variant'

