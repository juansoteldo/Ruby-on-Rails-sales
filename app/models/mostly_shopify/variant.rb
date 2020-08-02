# frozen_string_literal: true

require "mostly_shopify/base"

module MostlyShopify
  class Variant < Base
    def color?
      gift_card? && false || (@source.option1 == "yes")
    end

    def cover_up?
      gift_card? && false || (@source.option2 == "yes")
    end

    def temporary?
      gift_card? && false || (@source.option3 == "yes")
    end

    def gift_card?
      fulfillment_service == "gift_card"
    end

    def self.find(id)
      shopify_sources.select { |i| i.id == id }.map { |i| new(i) }
    end

    def self.all
      shopify_sources.map { |i| new(i) }
    end

    def self.deposits; end

    def self.shopify_sources
      Rails.cache.fetch(expires_in: 5.minutes) do
        ShopifyAPI::Variant.all params: { limit: 200 }
      end
    end

    def product
      return @source.product if @source&.respond_to?(:product)

      MostlyShopify::Product.for_variant self
    end
  end
end
