# frozen_string_literal: true

require "shopify_api"
require "mostly_shopify/base"
require "mostly_shopify/variant"

module MostlyShopify
  class Product < Base
    def self.find(id)
      shopify_sources.select { |i| i.id == id }.map { |i| new(i) }
    end

    def self.all
      shopify_sources.map { |i| new(i) }
    end

    def self.for_variant(_variant)
      all.find { |p| p.variants.any? { |v| v.id == _variant.id } }
    end

    def self.shopify_sources
      products = Rails.cache.fetch("shopify/products/all", expires_in: expire_in(15.minutes)) do
        ShopifyAPI::Product.all params: { limit: 200 }
      end
      raise "no-products-found" if products.nil?

      products
    rescue StandardError
      Rails.cache.delete("shopify/products/all")
      []
    end

    def final_payment?
      handle.include?("final")
    end

    def deposit?
      handle.include?("deposit")
    end

    def variants
      @source.variants.map { |v| MostlyShopify::Variant.new(v) }
    end

    def sub_title
      @source.title.sub(group_title, "").strip
    end

    def group_title
      title.sub("Final Payment", "").sub("Deposit", "").strip
    end
  end
end
