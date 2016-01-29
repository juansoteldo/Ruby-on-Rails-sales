module CTD
  module Shopify
    class Group
      attr_accessor :title, :products, :id

      def self.all
        products = Product.all
        groups = products.map do |product|
          product.title.sub( 'Final Payment', '' ).sub( 'Deposit', '').strip
        end.uniq.map do |name|
          self.new(name, products.select{|p| /^#{name}.*/.match(p.title) })
        end
        groups
      end

      def initialize(title, products)
        @id = SecureRandom.urlsafe_base64(nil, false)
        @title = title
        @products = products
      end
    end
  end
end

require 'ctd/shopify/product'
