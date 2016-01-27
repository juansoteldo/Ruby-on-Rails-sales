require 'ctd/shopify/base'

module CTD
  module Shopify
    class Product < CTD::Shopify::Base
      def self.all
        self.shopify_products.map{ |product| self.new(product) }
      end

      def self.shopify_products
        Rails.cache.fetch(expires_in: 12.hours) do
          ShopifyAPI::Product.find(:all)
        end
      end

      def initialize(product)
        @source = product
      end

      def is_final_payment?
        handle.include?('final')
      end

      def is_deposit?
        handle.include?('deposit')
      end

      def css_classes
        classes = []
        classes << 'final' if is_final_payment?
        classes << 'deposit' if is_deposit?
        classes.join(' ')
      end

      def variants
        @source.variants.map{|v| Variant.new(v)}
      end

      def sub_title
        @source.title.sub( group_title, '' ).strip
      end

      def group_title
        title.sub( 'Final Payment', '' ).sub( 'Deposit', '').strip
      end


    end
  end
end

require 'shopify_api'
require 'ctd/shopify/variant'

