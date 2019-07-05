# frozen_string_literal: true

require "shopify_api"
require "mostly_shopify/base"
require "mostly_shopify/variant"

module MostlyShopify
  class Product < Base

    def self.find(id)
      self.shopify_sources.select{|i| i.id == id }.map{ |i| self.new(i) }
    end

    def self.all
      self.shopify_sources.map{ |i| self.new(i) }
    end

    def self.shopify_sources
      Rails.cache.fetch(expires_in: 1.minutes) do
        ShopifyAPI::Product.all params: { limit: 200 }
      end
    end

    def is_final_payment?
      handle.include?('final')
    end

    def is_deposit?
      handle.include?('deposit')
    end

    def variants
      @source.variants.map{|v| MostlyShopify::Variant.new(v)}
    end

    def sub_title
      @source.title.sub( group_title, '' ).strip
    end

    def group_title
      title.sub( 'Final Payment', '' ).sub( 'Deposit', '').strip
    end
  end
end



