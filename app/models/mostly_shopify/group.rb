# frozen_string_literal: true

class MostlyShopify::Group
  attr_accessor :title, :products, :id

  def self.all
    products = Product.all
    groups = products.map do |product|
      product.title.sub("Final Payment", "").sub("Deposit", "").strip
    end.uniq.map do |name|
      new(name, products.select { |p| /^#{name}.*/.match(p.title) })
    end.reject do |group|
      group.products.select { |p| p.variants.count == 0 }.any?
    end
    groups
  end

  def initialize(title, products)
    @id = SecureRandom.urlsafe_base64(nil, false)
    @title = title
    @products = products
  end
end
